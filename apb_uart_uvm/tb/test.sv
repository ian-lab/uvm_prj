`timescale 1ns/1ps
package apb_uart_test;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_pkg::*;
    import apb_pkg::*;
    import modem_pkg::*;
    import apb_uart_rgm_pkg::*;
    import apb_uart_pkg::*;
    
    //-------------------------------
    // base test sequence
    //-------------------------------
    class base_test_sequence extends uvm_sequence #(uvm_sequence_item);
        `uvm_object_utils(base_test_sequence)
        `uvm_declare_p_sequencer(apb_uart_virtual_sequencer)
        uart_trans tr;
        modem_trans modem_tr; 
        apb_uart_rgm rgm;
        uvm_status_e status;
        bit [ 7:0] IER;
        bit [ 7:0] IIR;
        bit [ 7:0] FCR;
        bit [ 7:0] LCR;
        bit [ 7:0] MCR;
        bit [ 7:0] LSR;
        bit [ 7:0] MSR;
        bit [15:0] DIV;
        bit [ 7:0] rx_data;
        bit [ 7:0] tx_data;
        bit [ 7:0] reg_data;
        int no_tx;
        int no_rx;
        int rx_fifo_threshold;
        bit parity_err; 
        bit frame_err;
        bit rx_break;
        
        function new(string name="base_test_sequence");
            super.new(name);
        endfunction 

        virtual task body();
            DIV = 16'h2;
            LCR = 7'h03;
            IER = 7'h0;
            FCR = 7'b0;
            uart_config();
        endtask
        virtual task uart_config();
            case (FCR[7:6])
                2'b00: rx_fifo_threshold = 1;
                2'b01: rx_fifo_threshold = 4;
                2'b10: rx_fifo_threshold = 8;
                2'b11: rx_fifo_threshold = 14;
            endcase
            rgm.LCR.write(status, {1'b0, LCR[6:0]});
            rgm.FCR.write(status, {FCR[7:6], 6'b0});
            rgm.DIV1.write(status, DIV[7:0]);
            rgm.DIV2.write(status, DIV[15:8]);
            rgm.IER.write(status, {4'b0, IER[3:0]});
            p_sequencer.uart_rx_cfg.LCR = LCR;
            p_sequencer.uart_tx_cfg.LCR = LCR;
        endtask
    endclass

    //-------------------------------
    // reg test sequence
    //-------------------------------
    class reg_test_sequence extends base_test_sequence;
        `uvm_object_utils(reg_test_sequence)
        
        function new(string name="reg_test_sequence");
            super.new(name);
        endfunction
        
        virtual task body();
            rgm = p_sequencer.rgm;
            rgm.reset();
            @(posedge p_sequencer.apb_vif.rstn);

            // detect reset value
            // IER RW 0
            rgm.IER.read(status, IER);
            if(IER != 8'h0)
                `uvm_error("scoreboard",$sformatf("IER Reset Value detect error, expected Value is 'h0, actual Value is 'h%2x",IER))
            else
                `uvm_info("scoreboard",$sformatf("IER Reset Value error detect successful"),UVM_LOW)
            // IIR RO C0
            rgm.IIR.read(status, IIR);
            if(IIR != 8'hc1)
                `uvm_error("scoreboard",$sformatf("IIR Reset Value detect error, expected Value is 'hc1, actual Value is 'h%2x",IIR))
            else
                `uvm_info("scoreboard",$sformatf("IIR Reset Value detect successful"),UVM_LOW)
            // FCR WO C0
            rgm.FCR.peek(status, FCR);
            if(FCR != 8'hc0)
                `uvm_error("scoreboard",$sformatf("FCR Reset Value detect error, expected Value is 'hc0, actual Value is 'h%2x",FCR))
            else
                `uvm_info("scoreboard",$sformatf("FCR Reset Value detect successful"),UVM_LOW)  
            // LCR RW 0
            rgm.LCR.read(status, LCR);
            if(LCR != 8'h3)
                `uvm_error("scoreboard",$sformatf("LCR Reset Value detect error, expected Value is 'h3, actual Value is 'h%2x",LCR))
            else
                `uvm_info("scoreboard",$sformatf("LCR Reset Value detect successful"),UVM_LOW)  
            // MCR RW 0
            rgm.MCR.read(status, MCR);
            if(MCR != 8'h0)
                `uvm_error("scoreboard",$sformatf("MCR Reset Value detect error, expected Value is 'h0, actual Value is 'h%2x",MCR))
            else
                `uvm_info("scoreboard",$sformatf("MCR Reset Value detect successful"),UVM_LOW)  
            // LSR RO 'H60
            rgm.LSR.read(status, LSR);
            if(LSR != 8'h60)
                `uvm_error("scoreboard",$sformatf("LSR Reset Value detect error, expected Value is 'h60, actual Value is 'h%2x",LSR))
            else
                `uvm_info("scoreboard",$sformatf("LSR Reset Value detect successful"),UVM_LOW)  
            // MSR RO f0
            rgm.MSR.read(status, MSR);
            if(MSR != 8'hf0)
                `uvm_error("scoreboard",$sformatf("MSR Reset Value detect error, expected Value is 'hf0, actual Value is 'h%2x",MSR))
            else
                `uvm_info("scoreboard",$sformatf("MSR Reset Value detect successful"),UVM_LOW)  
            // DIV1 RW 0
            rgm.DIV1.read(status, DIV);
            if(DIV[7:0] != 8'h0)
                `uvm_error("scoreboard",$sformatf("DIV1 Reset Value detect error, expected Value is 'h0, actual Value is 'h%2x",DIV[7:0]))
            else
                `uvm_info("scoreboard",$sformatf("DIV1 Reset Value detect successful"),UVM_LOW)
            // DIV2 RW 0
            rgm.DIV2.read(status, DIV);
            if(DIV[15:8] != 8'h0)
                `uvm_error("scoreboard",$sformatf("DIV2 Reset Value detect error, expected Value is 'hc1, actual Value is 'h%2x",DIV[15:8]))
            else
                `uvm_info("scoreboard",$sformatf("DIV2 Reset Value detect successful"),UVM_LOW)
            
            // detect ro / wo / rw
            // ro
            IIR = $urandom();
            LSR = $urandom();
            MSR = $urandom();
            rgm.FCR.write(status, IIR);
            rgm.IIR.read(status, reg_data);
            if(reg_data != 8'hc1)
                `uvm_error("scoreboard",$sformatf("read IIR error, expected Value is 'hc1, actual Value is 'h%2x",reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read IIR right"),UVM_LOW)
            rgm.FCR.write(status, ~IIR);
            rgm.IIR.read(status, reg_data);
            if(reg_data != 8'hc1)
                `uvm_error("scoreboard",$sformatf("read IIR error, expected Value is 'hc1, actual Value is 'h%2x",reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read IIR right"),UVM_LOW)   

            rgm.LSR.write(status, LSR);
            rgm.LSR.read(status, reg_data);
            if(reg_data != 8'h60)
                `uvm_error("scoreboard",$sformatf("read LSR error, expected Value is 'h60, actual Value is 'h%2x",reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read LSR right"),UVM_LOW)
            rgm.LSR.write(status, ~LSR);
            rgm.LSR.read(status, reg_data);
            if(reg_data != 8'h60)
                `uvm_error("scoreboard",$sformatf("read LSR error, expected Value is 'h60, actual Value is 'h%2x",reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read LSR right"),UVM_LOW)

            rgm.MSR.write(status, MSR);
            rgm.MSR.read(status, reg_data);
            if(reg_data != 8'hf0)
                `uvm_error("scoreboard",$sformatf("read MSR error, expected Value is 'hf0, actual Value is 'h%2x",reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read MSR right"),UVM_LOW)
            rgm.MSR.write(status, ~MSR);
            rgm.MSR.read(status, reg_data);
            if(reg_data != 8'hf0)
                `uvm_error("scoreboard",$sformatf("read MSR error, expected Value is 'hf0, actual Value is 'h%2x",reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read MSR right"),UVM_LOW)
            // rw
            IER = $urandom();
            LCR = $urandom();
            MCR = $urandom();
            DIV = $urandom();
            rgm.IER.write(status, IER);
            rgm.IER.read(status, reg_data);
            if(IER[3:0] != reg_data)
                `uvm_error("scoreboard",$sformatf("read IER reg error, expected IER is 'h%2x, actual IER is 'h%2x",IER[3:0], reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read IER reg right"),UVM_LOW)
            rgm.IER.write(status, ~IER);
            rgm.IER.read(status, reg_data);
            if(({4'b0, ~IER[3:0]}) != reg_data)
                `uvm_error("scoreboard",$sformatf("read IER reg error, expected IER is 'h%2x, actual IER is 'h%2x",~IER[3:0], reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read IER reg right"),UVM_LOW)
            rgm.LCR.write(status, LCR);
            rgm.LCR.read(status, reg_data);
            if(LCR != reg_data)
                `uvm_error("scoreboard",$sformatf("read LCR reg error, expected LCR is 'h%2x, actual LCR is 'h%2x",LCR, reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read LCR reg right"),UVM_LOW)
             rgm.LCR.write(status, ~LCR);
            rgm.LCR.read(status, reg_data);
            if(~LCR != reg_data)
                `uvm_error("scoreboard",$sformatf("read LCR reg error, expected LCR is 'h%2x, actual LCR is 'h%2x",~LCR, reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read LCR reg right"),UVM_LOW)
            rgm.MCR.write(status, MCR);
            rgm.MCR.read(status, reg_data);
            if(MCR[4:0] != reg_data)
                `uvm_error("scoreboard",$sformatf("read MCR reg error, expected MCR is 'h%2x, actual MCR is 'h%2x",MCR[4:0], reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read MCR reg right"),UVM_LOW)
            rgm.MCR.write(status, ~MCR);
            rgm.MCR.read(status, reg_data);
            if(({3'b0, ~MCR[4:0]}) != reg_data)
                `uvm_error("scoreboard",$sformatf("read MCR reg error, expected MCR is 'h%2x, actual MCR is 'h%2x",~MCR[4:0], reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read MCR reg right"),UVM_LOW)
            rgm.DIV1.write(status, DIV[7:0]);
            rgm.DIV1.read(status, reg_data);
            if(DIV[7:0] != reg_data)
                `uvm_error("scoreboard",$sformatf("read DIV1 reg error, expected DIV1 is 'h%2x, actual DIV1 is 'h%2x",DIV[7:0], reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read DIV1 reg right"),UVM_LOW)
            rgm.DIV1.write(status, ~DIV[7:0]);
            rgm.DIV1.read(status, reg_data);
            if(~DIV[7:0] != reg_data)
                `uvm_error("scoreboard",$sformatf("read DIV1 reg error, expected DIV1 is 'h%2x, actual DIV1 is 'h%2x",~DIV[7:0], reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read DIV1 reg right"),UVM_LOW)
            rgm.DIV2.write(status, DIV[15:8]);
            rgm.DIV2.read(status, reg_data);
            if(DIV[15:8] != reg_data)
                `uvm_error("scoreboard",$sformatf("read DIV2 reg error, expected DIV2 is 'h%2x, actual DIV2 is 'h%2x",DIV[15:8], reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read DIV2 reg right"),UVM_LOW)
            rgm.DIV2.write(status, ~DIV[15:8]);
            rgm.DIV2.read(status, reg_data);
            if(~DIV[15:8] != reg_data)
                `uvm_error("scoreboard",$sformatf("read DIV2 reg error, expected DIV2 is 'h%2x, actual DIV2 is 'h%2x",~DIV[15:8], reg_data))
            else
                `uvm_info("scoreboard",$sformatf("read DIV2 reg right"),UVM_LOW)
            // wo
            FCR = $urandom();
            rgm.FCR.write(status, FCR);
            rgm.FCR.peek(status, reg_data);
            if(FCR != reg_data)
                `uvm_error("scoreboard",$sformatf("write FCR reg error, expected FCR is 'h%2x, actual LCR is 'h%2x",FCR, reg_data))
            else
                `uvm_info("scoreboard",$sformatf("write FCR reg right"),UVM_LOW)
            rgm.FCR.write(status, ~FCR);
            rgm.FCR.peek(status, reg_data);
            if(~FCR != reg_data)
                `uvm_error("scoreboard",$sformatf("write FCR reg error, expected FCR is 'h%2x, actual LCR is 'h%2x",~FCR, reg_data))
            else
                `uvm_info("scoreboard",$sformatf("write FCR reg right"),UVM_LOW)
        endtask
    endclass 

    //-------------------------------
    // baud test sequence
    //-------------------------------
    class baud_test_sequence extends base_test_sequence;
        `uvm_object_utils(baud_test_sequence)
        
        function new(string name="baud_test_sequence");
            super.new(name);
        endfunction
        
        virtual task body();
            rgm = p_sequencer.rgm;
            rgm.reset();
            @(posedge p_sequencer.apb_vif.rstn);
            repeat(1000)begin
                tr =new("tr");
                tr.randomize();
                DIV = tr.baud_div;
                rgm.DIV1.write(status, DIV[7:0]);
                rgm.DIV2.write(status, DIV[15:8]);
                @(posedge p_sequencer.irq_vif.baud_out);
                @(posedge p_sequencer.irq_vif.baud_out);
            end
        endtask
    endclass 

    //-------------------------------
    // rx tx test sequence
    //-------------------------------
    class rx_tx_base_test_sequence extends base_test_sequence;
        `uvm_object_utils(rx_tx_base_test_sequence)
        
        function new(string name="rx_tx_base_test_sequence");
            super.new(name);
        endfunction
        
        virtual task body();
            rgm = p_sequencer.rgm;
            rgm.reset();
            @(posedge p_sequencer.apb_vif.rstn);
            repeat(1000)begin
                DIV = $urandom_range(2,10);
                IER = 7'h0;
                FCR = 7'b0;
                LCR = $urandom();
                uart_config();
                fork
                    begin
                        `uvm_do_on_with(tr, p_sequencer.uart_rx_sqr, {LCR == local::LCR;})
                        rgm.LSR.read(status,reg_data);
                        while(!reg_data[0])
                            rgm.LSR.read(status, reg_data);
                        rgm.rxd.read(status, rx_data);
                    end
                    begin
                        tx_data = $urandom();
                        case(LCR[1:0])
                            2'b00: tx_data = {3'b0, tx_data[4:0]};
                            2'b01: tx_data = {2'b0, tx_data[5:0]};
                            2'b10: tx_data = {1'b0, tx_data[6:0]};
                            2'b11: tx_data = tx_data[7:0];
                        endcase
                        rgm.LSR.read(status, reg_data);
                        while(!reg_data[5])
                            rgm.LSR.read(status, reg_data);
                        rgm.txd.write(status, tx_data);
                    end
                join
                rgm.LSR.read(status,reg_data);
                while(!reg_data[6])
                    rgm.LSR.read(status, reg_data);
            end
        endtask;
    endclass 

    //-------------------------------
    // rx tx interrupt sequence
    //-------------------------------
    class rx_tx_int_sequence extends rx_tx_base_test_sequence;
        `uvm_object_utils(rx_tx_int_sequence)
       
        function new(string name="rx_tx_int_sequence");
            super.new(name);
        endfunction

        task body();
            rgm = p_sequencer.rgm;
            rgm.reset();
            @(posedge p_sequencer.apb_vif.rstn);
            repeat(1000) begin
                DIV = $urandom_range(2,10);
                IER = 7'h3;
                FCR = $urandom();
                LCR = $urandom();
                uart_config();
                no_tx = rx_fifo_threshold;
                no_rx = rx_fifo_threshold ;
                fork
                    begin
                        for(int i = 0; i < rx_fifo_threshold; i++)
                            `uvm_do_on_with(tr, p_sequencer.uart_rx_sqr, {LCR == local::LCR;})
                    end
                    begin
                        while(no_rx > 0 || no_tx > 0) begin
                            if(!p_sequencer.irq_vif.irq)begin
                                @(posedge p_sequencer.irq_vif.irq);
                            end
                            rgm.IIR.read(status, reg_data);
                            if(!reg_data[0])begin
                                case (reg_data[3:0])
                                    4'h4 : begin
                                        for(int i = 0; i < rx_fifo_threshold; i++)begin
                                            rgm.rxd.read(status, rx_data);
                                            no_rx--;
                                        end
                                    end     
                                    4'h2 : begin
                                        tx_data = $urandom();
                                        case(LCR[1:0])
                                            2'b00: tx_data = {3'b0, tx_data[4:0]};
                                            2'b01: tx_data = {2'b0, tx_data[5:0]};
                                            2'b10: tx_data = {1'b0, tx_data[6:0]};
                                            2'b11: tx_data = tx_data[7:0];
                                        endcase
                                        rgm.txd.write(status, tx_data);
                                        no_tx--;
                                    end   
                                endcase
                            end
                        end
                    end
                join
                rgm.LSR.read(status,reg_data);
                while(!reg_data[6])
                    rgm.LSR.read(status, reg_data);
            end
        endtask
    endclass 

    //-------------------------------
    // rx  error test sequence
    //-------------------------------
    class rx_error_test_sequence extends base_test_sequence;
        `uvm_object_utils(rx_error_test_sequence)
        
        function new(string name="rx_error_test_sequence");
            super.new(name);
        endfunction
        
        virtual task body();
            rgm = p_sequencer.rgm;
            rgm.reset();
            @(posedge p_sequencer.apb_vif.rstn);
            repeat(1000)begin
                DIV = $urandom_range(2,10);
                IER = 4'h5;
                LCR = $urandom();
                FCR = $urandom();
                uart_config();
                parity_err = $urandom();
                frame_err = $urandom();
                rx_break = $urandom();
                fork
                    begin
                        for(int i = 0; i < rx_fifo_threshold; i++)
                            `uvm_do_on_with(tr, p_sequencer.uart_rx_sqr, 
                                            { LCR == local::LCR;
                                              parity_err == local::parity_err;
                                              frame_err == local::frame_err;
                                              rx_break == local::rx_break;})
                    end
                    begin
                        if(!p_sequencer.irq_vif.irq)
                            @(posedge p_sequencer.irq_vif.irq);
                        rgm.IIR.read(status, reg_data);
                        if(reg_data[3:0] == 4'd4)
                            for(int i = 0; i < rx_fifo_threshold; i++)begin
                                rgm.rxd.read(status, rx_data);
                                rgm.IIR.read(status, reg_data);
                                rgm.LSR.read(status, reg_data);
                            end 
                    end
                join
            end
        endtask;
    endclass 

    //-------------------------------
    // modem test sequence
    //-------------------------------
    class modem_sequence extends base_test_sequence;
         `uvm_object_utils(modem_sequence)
        
        function new(string name="modem_sequence");
            super.new(name);
        endfunction 

        virtual task body();
            rgm = p_sequencer.rgm;
            rgm.reset();
            @(posedge p_sequencer.apb_vif.rstn);
            IER = 7'h8;
            rgm.IER.write(status, {4'b0, IER});

            fork
                forever begin
                    while(!p_sequencer.irq_vif.irq)
                        @(posedge p_sequencer.irq_vif.irq);
                    rgm.IIR.read(status, reg_data);
                    rgm.MSR.read(status, MSR);
                end
            join_none
            //Normal
            repeat(5000) begin
                fork
                    begin
                        MCR = $urandom();
                        MCR[4] = 0; //Normal
                        rgm.MCR.write(status, {3'b0, MCR[4:0]});
                        
                    end
                    `uvm_do_on(modem_tr, p_sequencer.modem_sqr);
                join 
            end
            //LOOP
            repeat(5000) begin
                fork
                    begin
                        MCR = $urandom();
                        MCR[4] = 1; //Loop
                        rgm.MCR.write(status, {3'b0, MCR[4:0]});
                    end
                    `uvm_do_on(modem_tr, p_sequencer.modem_sqr);
                join 
            end
        endtask
    endclass

    //-------------------------------
    // base test 
    //-------------------------------
    class apb_uart_base_test extends uvm_test;
        `uvm_component_utils(apb_uart_base_test)
        apb_uart_env env;

        function new(string name="apb_uart_base_test", uvm_component parent);
            super.new(name, parent);
        endfunction 

        function void build_phase(uvm_phase phase);
            env = apb_uart_env::type_id::create("env",this);
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            do_run();
            phase.drop_objection(this);
        endtask 

        virtual task do_run();

        endtask
    endclass 
    //-------------------------------
    // reg test 
    //-------------------------------
    class apb_uart_reg_test extends apb_uart_base_test;
        `uvm_component_utils(apb_uart_reg_test)
        reg_test_sequence reg_seq;

        function new(string name="apb_uart_reg_test", uvm_component parent);
            super.new(name, parent);
        endfunction 

        task do_run();
            reg_seq = reg_test_sequence::type_id::create("reg_seq", this);
            reg_seq.start(env.vir_sqr);
            #100;
        endtask 
    endclass 
    //-------------------------------
    // baud test 
    //-------------------------------
    class apb_uart_baud_test extends apb_uart_base_test;
        `uvm_component_utils(apb_uart_baud_test)
        baud_test_sequence baud_seq;

        function new(string name="apb_uart_baud_test", uvm_component parent);
            super.new(name, parent);
        endfunction 

        task do_run();
            baud_seq = baud_test_sequence::type_id::create("baud_seq", this);
            baud_seq.start(env.vir_sqr);
            #100;
        endtask 
    endclass 
    
    //-------------------------------
    // rx tx test 
    //-------------------------------
    class apb_uart_rx_tx_test extends apb_uart_base_test;
        `uvm_component_utils(apb_uart_rx_tx_test)
        rx_tx_base_test_sequence rx_tx_seq;

        function new(string name="apb_uart_rx_tx_test", uvm_component parent);
            super.new(name, parent);
        endfunction 

        task do_run();
            rx_tx_seq = rx_tx_base_test_sequence::type_id::create("rx_tx_seq",this);
            rx_tx_seq.start(env.vir_sqr);
            #100;
        endtask 
    endclass 
    
    //-------------------------------
    // int test 
    //-------------------------------
     class apb_uart_rx_tx_int_test extends apb_uart_base_test;
        `uvm_component_utils(apb_uart_rx_tx_int_test)
        rx_tx_int_sequence rx_tx_int_seq;

        function new(string name="apb_uart_rx_tx_int_test", uvm_component parent);
            super.new(name, parent);
        endfunction 

        task do_run();
            rx_tx_int_seq = rx_tx_int_sequence::type_id::create("rx_tx_int_seq",this);
            rx_tx_int_seq.start(env.vir_sqr);
            #100;
        endtask 
    endclass

    //-------------------------------
    // error test 
    //-------------------------------
    class apb_uart_rx_error_test extends apb_uart_base_test;
        `uvm_component_utils(apb_uart_rx_error_test)
        rx_error_test_sequence rx_error_test_seq;

        function new(string name="apb_uart_rx_error_test", uvm_component parent);
            super.new(name, parent);
        endfunction 

        task do_run();
            rx_error_test_seq = rx_error_test_sequence::type_id::create("rx_error_test_seq",this);
            rx_error_test_seq.start(env.vir_sqr);
            #100;
        endtask 
    endclass

    //-------------------------------
    // mdoem test 
    //-------------------------------
    class apb_uart_modem_test extends apb_uart_base_test;
        `uvm_component_utils(apb_uart_modem_test)
        modem_sequence modem_seq;

        function new(string name="apb_uart_modem_test", uvm_component parent);
            super.new(name, parent);
        endfunction 

        task do_run();
            modem_seq = modem_sequence::type_id::create("modem_seq",this);
            modem_seq.start(env.vir_sqr);
            #100;
        endtask 
    endclass
endpackage