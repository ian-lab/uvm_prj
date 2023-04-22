package uart_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import apb_uart_rgm_pkg::*;

    class uart_trans extends uvm_sequence_item;
        rand bit [15:0] baud_div;       // baud div
        rand bit [ 7:0] data;           // data
        rand bit [ 7:0] LCR;            // LCR reg
        rand int        idle;           // idle cycles
        rand bit        parity_err;     // parity error
        rand bit        frame_err;      // stop bit error
        rand bit        rx_break;
        constraint cstr{
            soft idle inside {[1:10]};
            soft LCR == 8'h03;
            soft parity_err == 0;
            soft frame_err == 0;
            soft rx_break == 0;
            baud_div inside {   16'h0001, 16'h0002, 16'h0004, 16'h0008,
                                16'h0010, 16'h0020, 16'h0040, 16'h0080,
                                16'h0100, 16'h0200, 16'h0400, 16'h0800,
                                16'h1000, 16'h2000, 16'h4000, 16'h8000,
                                16'hfffe, 16'hfffd, 16'hfffb, 16'hfff7,
                                16'hffef, 16'hffdf, 16'hffbf, 16'hff7f,
                                16'hfeff, 16'hfdff, 16'hfbff, 16'hf7ff,
                                16'hefff, 16'hdfff, 16'hbfff, 16'h7fff,
                                16'h00ff, 16'hff00, 16'hffff};
        }
        `uvm_object_utils_begin(uart_trans)
            `uvm_field_int(baud_div, UVM_ALL_ON)
            `uvm_field_int(data, UVM_ALL_ON)
            `uvm_field_int(LCR, UVM_ALL_ON)
            `uvm_field_int(idle, UVM_ALL_ON)
            `uvm_field_int(parity_err, UVM_ALL_ON)
            `uvm_field_int(frame_err, UVM_ALL_ON)
            `uvm_field_int(rx_break, UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name="uart_trans");
            super.new(name);
        endfunction 
    endclass 
    
    class uart_cfg extends uvm_object;
        `uvm_object_utils(uart_cfg)
        uvm_active_passive_enum is_active = UVM_ACTIVE;
        bit [7:0] LCR = 8'h03;
        function new(string name="uart_cfg");
            super.new(name);
        endfunction 
    endclass 

    class uart_sequencer extends uvm_sequencer #(uart_trans);
        `uvm_component_utils(uart_sequencer)
        function new(string name="uart_sequencer", uvm_component parent);
            super.new(name, parent);
        endfunction 
    endclass 

    class uart_driver extends uvm_driver #(uart_trans);
        `uvm_component_utils(uart_driver)
        virtual uart_intf uart_vif;
        bit [15:0] drv_data;

        function new(string name="uatr_driver", uvm_component parent);
            super.new(name, parent);
        endfunction 

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual uart_intf)::get(this, "", "uart_vif", uart_vif))
                `uvm_fatal("get vif", "get vif failed")
        endfunction

        task run_phase(uvm_phase phase);
            send_pkg();
        endtask 

        task send_pkg();
            int bit_cnt=0; // send data counter
            uart_vif.data <= 1'b1;
            repeat(16) @(posedge uart_vif.clk);
            forever begin
                seq_item_port.get_next_item(req);
               
                case(req.LCR[1:0])
                    2'b00: drv_data=req.data[4:0];
                    2'b01: drv_data=req.data[5:0];
                    2'b10: drv_data=req.data[6:0];
                    2'b11: drv_data=req.data;
                endcase
                if(req.rx_break == 1'b1)
                    drv_data = 8'b0;
                // `uvm_info(get_type_name(), $sformatf("LCR is 'h%2x, drive data is 'h%2x, parity_err is %1x, frame_err is %1x, rx_break is %1x", req.LCR, drv_data, req.parity_err, req.frame_err, req.rx_break),  UVM_LOW)
                
                //idle
                repeat(req.idle) @(uart_vif.clk);
                //start
                uart_vif.data <= 1'b0;
                repeat(16) @(posedge uart_vif.clk);
                bit_cnt=0;
                //0-4
                while (bit_cnt < 5) begin
                    uart_vif.data <= drv_data[bit_cnt];
                    repeat(16) @(posedge uart_vif.clk);
                    bit_cnt++;
                end
                //5-7
                if(req.LCR[1:0] > 2'b00)begin
                    uart_vif.data <= drv_data[5];
                    repeat(16) @(posedge uart_vif.clk);
                end
                if(req.LCR[1:0] > 2'b01)begin
                    uart_vif.data <= drv_data[6];
                    repeat(16) @(posedge uart_vif.clk);
                end
                if(req.LCR[1:0] > 2'b10)begin
                    uart_vif.data <= drv_data[7];
                    repeat(16) @(posedge uart_vif.clk);
                end
                // parity LCR[3]==1, enable parity
                if (req.LCR[3]) begin
                    if(req.rx_break)
                        uart_vif.data = 1'b0;
                    else if(req.LCR[5])  // parity LCR[5]==1 -> stick parity = ~LCR[4]
                        if(req.parity_err)
                            uart_vif.data <= req.LCR[4]; 
                        else
                            uart_vif.data <= ~req.LCR[4];    
                    else
                        if(req.parity_err)
                             uart_vif.data <= ~calParity(req.LCR[4], drv_data);     
                        else 
                            uart_vif.data <= calParity(req.LCR[4], drv_data); // LCR[4]==1 -> even parity   
                    repeat(16) @(posedge uart_vif.clk);
                end
                // stop
                if(req.frame_err | req.rx_break)
                    uart_vif.data = 1'b0;
                else
                    uart_vif.data = 1'b1;
                repeat(8) @(posedge uart_vif.clk);
                // LCR[2]==1, 2 or 1.5 stop bits
                uart_vif.data = 1'b1;
                if(req.LCR[2])begin
                    if(req.LCR[1:0]==2'b00)begin
                        // 0.5 bit
                        repeat(8) @(posedge uart_vif.clk);
                    end
                    else begin
                        // 1 bit
                        repeat(16) @(posedge uart_vif.clk);
                    end  
                end
                uart_vif.data = 1'b1;
                seq_item_port.item_done();
            end
        endtask 

        function bit calParity(bit par_type, bit [7:0] data);
            if(par_type) 
                return ^data;    // even parity
            else
                return ~(^data); // odd parity
        endfunction
    endclass 

    class uart_monitor extends uvm_monitor;
        `uvm_component_utils(uart_monitor)
        uvm_analysis_port #(uart_trans) ap;
        virtual uart_intf uart_vif;
        uart_cfg cfg;
        uart_trans tr;
        bit parity;
        bit stop;
        function new(string name="uart_monitor", uvm_component parent);
            super.new(name, parent);
        endfunction 

        function void build_phase(uvm_phase phase);
            ap = new("uart_ap", this);
            if(!uvm_config_db#(virtual uart_intf)::get(this,"","uart_vif",uart_vif))
                `uvm_fatal("get vif","get vif failed")
            if(!uvm_config_db #(uart_cfg)::get(this,"","uart_cfg", cfg))
                `uvm_fatal("get cfg","get config failed")
        endfunction

        task run_phase(uvm_phase phase);
            forever begin
                tr = new("tr");
                rcv_data();
                `uvm_info(get_type_name(), $sformatf("LCR is 'h%2x, monitor data is 'h%2x, parity_err is 'h%1x, frame_err is 'h%1x, rx_break is %1x", cfg.LCR, tr.data, tr.parity_err, tr.frame_err, tr.rx_break), UVM_LOW)
                tr.LCR = cfg.LCR;
                ap.write(tr);
            end
        endtask

        task rcv_data();
            @(negedge uart_vif.data)
            parity = 0;
            stop = 0;
            repeat(23) @(posedge uart_vif.clk);
            // bit 0 - 4
            tr.data[0] = uart_vif.data;
            repeat(16) @(posedge uart_vif.clk);
            tr.data[1] = uart_vif.data;
            repeat(16) @(posedge uart_vif.clk);
            tr.data[2] = uart_vif.data;
            repeat(16) @(posedge uart_vif.clk);
            tr.data[3] = uart_vif.data;
            repeat(16) @(posedge uart_vif.clk);
            tr.data[4] = uart_vif.data;
            repeat(16) @(posedge uart_vif.clk);
            // bit 5 or parity
            if(cfg.LCR[1:0] > 2'b00)begin
                tr.data[5] = uart_vif.data;
                repeat(16) @(posedge uart_vif.clk);
            end
            else if(cfg.LCR[3] && cfg.LCR[1:0] == 2'b00)begin
                parity = uart_vif.data;
                repeat(16) @(posedge uart_vif.clk);
            end
            // bit 6 or parity
            if (cfg.LCR[1:0] > 2'b01) begin
                tr.data[6] = uart_vif.data;
                repeat(16) @(posedge uart_vif.clk);
            end
            else if(cfg.LCR[3] && cfg.LCR[1:0] == 2'b01) begin
                parity = uart_vif.data;
                repeat(16) @(posedge uart_vif.clk);
            end
            // bit 7 or parity
            if (cfg.LCR[1:0] > 2'b10) begin
                tr.data[7] = uart_vif.data;
                repeat(16) @(posedge uart_vif.clk);
            end
            else if(cfg.LCR[3] && cfg.LCR[1:0] == 2'b10) begin
                parity = uart_vif.data;
                repeat(16) @(posedge uart_vif.clk);
            end
            // parity
            if(cfg.LCR[3] && (cfg.LCR[1:0] == 2'b11))begin
                parity = uart_vif.data;
                repeat(16) @(posedge uart_vif.clk);
            end
            // parity error detect
            if(cfg.LCR[3]) begin
                if(cfg.LCR[5]) begin
                    if(parity != ~cfg.LCR[4])
                        tr.parity_err = 1;
                    else
                        tr.parity_err = 0;
                end
                else if(parity != calParity(cfg.LCR[4], tr.data))
                    tr.parity_err = 1;
                else
                    tr.parity_err = 0;
            end
            //stop
            stop = uart_vif.data;
            if(stop == 1'b1)
                tr.frame_err = 1'b0;
            else
                tr.frame_err = 1'b1;   
            if(tr.data == 8'b0 && stop == 1'b0) 
                tr.rx_break = 1;       
        endtask 

        function bit calParity(bit par_type, bit [7:0] data);
            if(par_type) 
                return ^data;// even parity
            else
                return ~(^data); // odd parity
        endfunction
    endclass 

    class uart_agent extends uvm_agent;
        `uvm_component_utils(uart_agent)

        uvm_analysis_port #(uart_trans) ap;
        uart_driver drv;
        uart_monitor mon;
        uart_sequencer sqr;
        uart_cfg cfg;

        function new(string name="uart_agent", uvm_component parent);
            super.new(name,parent);
        endfunction 

        function void build_phase(uvm_phase phase);
            mon=uart_monitor::type_id::create("mon", this);
            if(!uvm_config_db #(uart_cfg)::get(this, "", "uart_cfg", cfg))
                `uvm_fatal("get cfg","get conifg failed")
            if(cfg.is_active) begin
                drv=uart_driver::type_id::create("drv", this);
                sqr=uart_sequencer::type_id::create("sqr",this);
            end
        endfunction

        function void connect_phase(uvm_phase phase);
            ap = mon.ap;
            if(cfg.is_active)begin
                drv.seq_item_port.connect(sqr.seq_item_export);
            end
        endfunction
    endclass

endpackage