package fifo_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class fifo_trans extends uvm_sequence_item;

        rand bit [31:0] data[$];
        bit data_valid;
        bit full, empty;

        `uvm_object_utils_begin(fifo_trans)
            // `uvm_field_int(data, UVM_ALL_ON)
        `uvm_object_utils_end

        constraint cr{
            soft data.size() inside {[10:20]};
        }

        function new(string name="fifo_trans");
            super.new(name);
        endfunction
    endclass
  

    class fifo_sequencer extends uvm_sequencer #(fifo_trans);
        `uvm_component_utils(fifo_sequencer)
        function new(string name="fifo_sequencer", uvm_component parent);
            super.new(name, parent);
        endfunction 
    endclass 

    class fifo_wr_driver extends uvm_driver #(fifo_trans);
        `uvm_component_utils(fifo_wr_driver)
        virtual fifo_intf fifo_wr_vif;
        int data_num;
        bit has_trans;

        function new(string name="fifo_wr_drv", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            `uvm_info("test","fifo_wr_driver", UVM_LOW)
            if(!uvm_config_db#(virtual fifo_intf)::get(this,"","fifo_vif",fifo_wr_vif))
                `uvm_fatal("get vif","get vif failed!!!")
        endfunction

        task run_phase(uvm_phase phase);
            fifo_wr_vif.en <= 0;
            has_trans = 0;
            wait(fifo_wr_vif.rstn == 1);
            forever begin
                fork
                    drv_one_pkt();
                    drv_idle();
                join
            end
        endtask

        task drv_one_pkt();
            seq_item_port.get_next_item(req);
            has_trans = 1;
            data_num = req.data.size();
            while (data_num--) begin
                // wait full == 0
                while(fifo_wr_vif.valid)begin
                    @(posedge fifo_wr_vif.clk);
                    fifo_wr_vif.en <= 0;
                    fifo_wr_vif.data <= 0;
                end
                // drive data 
                @(posedge fifo_wr_vif.clk);
                fifo_wr_vif.en <= 1;
                fifo_wr_vif.data <= req.data.pop_front();
            end
            has_trans = 0;
            seq_item_port.item_done();
        endtask
        
        task drv_idle();
            if(has_trans == 0)begin
                @(posedge fifo_wr_vif.clk);
                fifo_wr_vif.en <= 0;
                fifo_wr_vif.data <= 0;
            end

        endtask
    endclass

    class fifo_rd_driver extends uvm_driver #(fifo_trans);
        `uvm_component_utils(fifo_rd_driver)
        virtual fifo_intf fifo_rd_vif;
        bit has_trans;
        function new(string name="fifo_rd_drv", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            
            if(!uvm_config_db#(virtual fifo_intf)::get(this,"","fifo_vif",fifo_rd_vif))
                `uvm_fatal("get vif","get vif failed!!!")
        endfunction
        
        task run_phase(uvm_phase phase);
            int data_num;
            fifo_rd_vif.en <= 0;
            wait(fifo_rd_vif.rstn == 1);
            forever begin
                fork
                    drv_one_pkt();
                    drv_idle();
                join
            end
        endtask

        task drv_one_pkt();
            seq_item_port.get_next_item(req);
            has_trans = 1;
            while(fifo_rd_vif.valid)begin
                @(posedge fifo_rd_vif.clk);
                fifo_rd_vif.en <= 0;
             end
            @(posedge fifo_rd_vif.clk);
            fifo_rd_vif.en <= 1;
            while(fifo_rd_vif.valid)begin
                @(posedge fifo_rd_vif.clk);
                fifo_rd_vif.en <= 0;
             end
            has_trans = 0;
            seq_item_port.item_done();
        endtask
        
        task drv_idle();
            if(has_trans == 0)begin
                @(posedge fifo_rd_vif.clk);
                fifo_rd_vif.en <= 0;
            end
        endtask
    endclass

    class fifo_monitor extends uvm_monitor;
        `uvm_component_utils(fifo_monitor)
        uvm_analysis_port #(fifo_trans) ap;
        virtual fifo_intf fifo_vif;
        fifo_trans tr;

        function new(string name="fifo_mon", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            ap=new("fifo_ap",this);
            if(!uvm_config_db#(virtual fifo_intf)::get(this,"","fifo_vif",fifo_vif))
                `uvm_fatal("get vif","get vif failed!!!")
        endfunction

        task run_phase(uvm_phase phase);
            int data_num;
            forever begin
                tr = new();
                @(posedge fifo_vif.clk);
                if(fifo_vif.valid == 0 && fifo_vif.en == 1)
                    tr.data_valid = 1;
                else 
                    tr.data_valid = 0;
                tr.full = fifo_vif.valid;
                tr.data.push_back(fifo_vif.data);
                ap.write(tr);
                // `uvm_info("scb",$sformatf("monitor data is [%8h] data_valid is [%1b] ", fifo_vif.data, tr.data_valid ), UVM_LOW)
            end
        endtask
    endclass

    class fifo_wr_agent extends uvm_agent;
        `uvm_component_utils(fifo_wr_agent)
        uvm_analysis_port #(fifo_trans)  ap;
        fifo_wr_driver fifo_wr_drv;
        fifo_monitor fifo_mon;
        fifo_sequencer fifo_sqr;

        function new(string name="fifo_wr_agent", uvm_component parent);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            fifo_sqr=fifo_sequencer::type_id::create("fifo_sqr",this);
            fifo_wr_drv=fifo_wr_driver::type_id::create("fifo_wr_drv", this);
            fifo_mon=fifo_monitor::type_id::create("fifo_mon",this);
        endfunction

        function void connect_phase(uvm_phase phase);
            ap=fifo_mon.ap;
            fifo_wr_drv.seq_item_port.connect(fifo_sqr.seq_item_export);
        endfunction
    endclass

    class fifo_rd_agent extends uvm_agent;
        `uvm_component_utils(fifo_rd_agent)
        uvm_analysis_port #(fifo_trans)  ap;
        fifo_rd_driver fifo_rd_drv;
        fifo_monitor fifo_mon;
        fifo_sequencer fifo_sqr;

        function new(string name="fifo_rd_agent", uvm_component parent);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            fifo_sqr=fifo_sequencer::type_id::create("fifo_sqr",this);
            fifo_rd_drv=fifo_rd_driver::type_id::create("fifo_rd_drv", this);
            fifo_mon=fifo_monitor::type_id::create("fifo_mon",this);
        endfunction

        function void connect_phase(uvm_phase phase);
            ap=fifo_mon.ap;
            fifo_rd_drv.seq_item_port.connect(fifo_sqr.seq_item_export);
        endfunction
    endclass 

    class fifo_state_scoreboard extends uvm_component;
        `uvm_component_utils(fifo_state_scoreboard)
        virtual fifo_intf fifo_wr_vif;
        virtual fifo_intf fifo_rd_vif;
        uvm_tlm_analysis_fifo #(fifo_trans) wr_fifo;
        uvm_tlm_analysis_fifo #(fifo_trans) rd_fifo;
        fifo_trans wr_tr;
        fifo_trans rd_tr;
        bit [31:0] wr_data_q[$];
        bit [31:0] wr_data, rd_data;
        bit full;
        bit empty;
        bit ref_full;
        int wr_num,rd_num;
        int wr_ptr;
        int rd_ptr;

        function new(string name="fifo_state_scoreboard", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            wr_fifo = new("wr_fifo", this);
            rd_fifo = new("rd_fifo", this);
            if(!uvm_config_db#(virtual fifo_intf)::get(this,"","fifo_rd_vif",fifo_rd_vif))
                `uvm_fatal("get vif","get vif failed!!!")
            if(!uvm_config_db#(virtual fifo_intf)::get(this,"","fifo_wr_vif",fifo_wr_vif))
                `uvm_fatal("get vif","get vif failed!!!")
        endfunction

        task run_phase(uvm_phase phase);
            wr_num=0;
            fork
                monitor_wr;
                monitor_rd;
            join
        endtask

        task monitor_wr;
            forever begin
                wr_fifo.get(wr_tr);
                full = wr_tr.full;
                if(wr_tr.data_valid)begin
                    wr_num += 1;
                    // wr_ptr += 1;
                end
                // `uvm_info("scb",$sformatf("wr_ptr is [%2d] ", wr_ptr), UVM_LOW)
                if(full != ref_full)begin
                    `uvm_error("scb",$sformatf("full state is fault"))
                end
                ref_full = (wr_num == 32) ? 1 : 0;
            end
        endtask

        task monitor_rd;
            forever begin
                rd_fifo.get(rd_tr);
                fork
                    if(rd_tr.data_valid)begin
                        repeat(2)  @(posedge fifo_wr_vif.clk);
                        wr_num -= 1;
                        // rd_ptr += 1;
                        // `uvm_info("scb",$sformatf("rd_prt is [%2d] ", rd_ptr), UVM_LOW)
                    end
                join_none
            end
        endtask
    endclass

    class fifo_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(fifo_scoreboard)
        uvm_tlm_analysis_fifo #(fifo_trans) wr_fifo;
        uvm_tlm_analysis_fifo #(fifo_trans) rd_fifo;
        fifo_trans wr_tr;
        fifo_trans rd_tr;
        bit [31:0] wr_data_q[$];
        bit [31:0] wr_data, rd_data;
        bit full;
        bit empty;
        int error_cnt;

        int wr_total_num,rd_total_num;
        function new(string name="fifo_scoreboard", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            wr_fifo = new("wr_fifo", this);
            rd_fifo = new("rd_fifo", this);
        endfunction

        task run_phase(uvm_phase phase);
            wr_total_num = 0;
            rd_total_num = 0;
            error_cnt = 0;
            fork
                monitor_wr;
                monitor_rd;
            join
        endtask

        task monitor_wr;

            forever begin
                wr_fifo.get(wr_tr);
                if(wr_tr.data_valid)begin
                    wr_total_num += 1;
                    wr_data_q.push_back(wr_tr.data.pop_front());
                end
            end
        endtask

        task monitor_rd;
            forever begin
                rd_fifo.get(rd_tr);
                if(rd_tr.data_valid)begin
                    rd_total_num += 1;
                    if(wr_data_q.size == 0)
                        `uvm_fatal("scoreboard", "wr seque is empty")
                    wr_data = wr_data_q.pop_front();
                    rd_data = rd_tr.data.pop_front();
                    if(wr_data != rd_data)begin
                        `uvm_error("scb",$sformatf("wr_data[%8h] and rd_data[%8h]  is different", wr_data, rd_data))
                        error_cnt += 1;
                    end
                    else 
                        `uvm_info("scb",$sformatf("wr_data[%8h] and rd_data[%8h]  is same", wr_data, rd_data), UVM_LOW)
                end
            end
        endtask

        function void report_phase(uvm_phase phase);
            `uvm_info("scb","***********************", UVM_LOW)
            if(error_cnt == 0)begin
                `uvm_info("scb","****  successfull  ****", UVM_LOW)
            end
            else begin
                `uvm_info("scb","****  failed  ****", UVM_LOW)
            end
            `uvm_info("scb","***********************", UVM_LOW)
        endfunction
    endclass

    class fifo_env extends uvm_component;
        `uvm_component_utils(fifo_env)

        fifo_wr_agent fifo_wr_agt;
        fifo_rd_agent fifo_rd_agt;

        fifo_state_scoreboard fifo_ref;
        fifo_scoreboard fifo_scb;

        function new(string name="fifo_env", uvm_component parent);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            fifo_wr_agt = fifo_wr_agent::type_id::create("fifo_wr_agt", this);
            fifo_rd_agt = fifo_rd_agent::type_id::create("fifo_rd_agt", this);
            fifo_ref = fifo_state_scoreboard::type_id::create("fifo_ref", this);
            fifo_scb = fifo_scoreboard::type_id::create("fifo_scb", this);   
        endfunction

        function void connect_phase(uvm_phase phase);
            fifo_wr_agt.ap.connect(fifo_scb.wr_fifo.analysis_export);
            fifo_rd_agt.ap.connect(fifo_scb.rd_fifo.analysis_export);
            fifo_wr_agt.ap.connect(fifo_ref.wr_fifo.analysis_export);
            fifo_rd_agt.ap.connect(fifo_ref.rd_fifo.analysis_export);
        endfunction

    endclass


endpackage


