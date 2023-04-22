package modem_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import apb_uart_rgm_pkg::*;

    class modem_trans extends uvm_sequence_item;
        rand bit [7:0] modem_bits;
        bit kind;

        function new(string name="modem_trans");
            super.new();
        endfunction 

        `uvm_object_utils_begin(modem_trans)
            `uvm_field_int(modem_bits, UVM_ALL_ON)
            `uvm_field_int(kind, UVM_ALL_ON)
        `uvm_object_utils_end
    endclass  

    class modem_sequencer extends uvm_sequencer #(modem_trans);
        `uvm_component_utils(modem_sequencer)
        function new(string name="modem_sequencer", uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class modem_driver extends uvm_driver #(modem_trans);
        `uvm_component_utils(modem_driver)
        virtual modem_intf modem_vif;

        function new(string name="modem_driver", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            if(!uvm_config_db#(virtual modem_intf)::get(this, "", "modem_vif", modem_vif))
                `uvm_fatal("get vif", "get vif failed!!!")
        endfunction

        task run_phase(uvm_phase phase);
            modem_vif.cb_drv.nCTS <= 1'b0;
            modem_vif.cb_drv.nDSR <= 1'b0;
            modem_vif.cb_drv.nDCD <= 1'b0;
            modem_vif.cb_drv.nRI  <= 1'b0;
            forever begin
                seq_item_port.get_next_item(req);
                modem_vif.cb_drv.nCTS <= req.modem_bits[0];
                modem_vif.cb_drv.nDSR <= req.modem_bits[1];
                modem_vif.cb_drv.nDCD <= req.modem_bits[2];
                modem_vif.cb_drv.nRI  <= req.modem_bits[3];
                seq_item_port.item_done();
            end
        endtask
    endclass 

    class modem_monitor extends uvm_monitor;
        `uvm_component_utils(modem_monitor)
        uvm_analysis_port #(modem_trans) ap;
        virtual modem_intf modem_vif;
        modem_trans tr;

        function new(string name="modem_monitor", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            ap = new("modem_ap", this);
            tr = new("tr");
            if(!uvm_config_db#(virtual modem_intf)::get(this, "", "modem_vif", modem_vif))
                `uvm_fatal("set vif", "virtual interface set failed!!!")
        endfunction
        
        task run_phase(uvm_phase phase);
            wait(modem_vif.cb_mon.nRTS === 1'b1 || modem_vif.cb_mon.nRTS  === 1'b0);
            fork
                forever begin
                    @(modem_vif.cb_mon.nCTS, modem_vif.cb_mon.nDSR, modem_vif.cb_mon.nDCD, modem_vif.cb_mon.nRI);
                    @(posedge modem_vif.clk);
                    @(posedge modem_vif.clk);
                    tr.modem_bits[0] = modem_vif.cb_mon.nCTS;
                    tr.modem_bits[1] = modem_vif.cb_mon.nDSR;
                    tr.modem_bits[2] = modem_vif.cb_mon.nDCD;
                    tr.modem_bits[3] = modem_vif.cb_mon.nRI ;
                    tr.kind = 0;
                    `uvm_info("scoreboard",$sformatf("nCTS is %1b, nDSR is %1b, nDCD is %1b, nRI is %1b", tr.modem_bits[0], tr.modem_bits[1], tr.modem_bits[2], tr.modem_bits[3]),UVM_LOW)
                    ap.write(tr);
                end
                forever begin
                    @(modem_vif.cb_mon.nRTS, modem_vif.cb_mon.nDTR, modem_vif.cb_mon.OUT1, modem_vif.cb_mon.OUT2);
                    @(posedge modem_vif.clk);
                    @(posedge modem_vif.clk);
                    tr.modem_bits[4] = modem_vif.cb_mon.nRTS;
                    tr.modem_bits[5] = modem_vif.cb_mon.nDTR;
                    tr.modem_bits[6] = modem_vif.cb_mon.OUT1;
                    tr.modem_bits[7] = modem_vif.cb_mon.OUT2;
                    tr.kind = 1;
                    `uvm_info("scoreboard",$sformatf("nRTS is %1b, nDTR is %1b, OUT1 is %1b, OUT2 is %1b", tr.modem_bits[4], tr.modem_bits[4], tr.modem_bits[6], tr.modem_bits[7]),UVM_LOW)
                    ap.write(tr);
                end
            join
        endtask
    endclass 

    class modem_agent extends uvm_agent;
        `uvm_component_utils(modem_agent)
        uvm_analysis_port #(modem_trans) ap;
        modem_driver drv;
        modem_monitor mon;
        modem_sequencer sqr;

        function new(string name="modem_agent", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            mon=modem_monitor::type_id::create("mon", this);
            drv=modem_driver::type_id::create("drv", this);
            sqr=modem_sequencer::type_id::create("sqr",this);
        endfunction

        function void connect_phase(uvm_phase phase);
            ap = mon.ap;
            drv.seq_item_port.connect(sqr.seq_item_export);
        endfunction
    endclass

endpackage