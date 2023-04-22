package slave_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import master_pkg::*;

    class slave_driver extends uvm_driver #(master_trans);
        `uvm_component_utils(slave_driver)

        virtual slave_intf slave_vif;
        int i; // packet cnt
        // master_trans master_tr;

        function new(string name="slave_driver", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual slave_intf)::get(this, "", "slave_vif", slave_vif))
                `uvm_fatal("set vif", "get slave vif failed!!!")
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            while(slave_vif.rst)begin
                @(slave_vif.cb_mon);
            end
            forever begin
                @(slave_vif.cb_mon )
                    slave_vif.credit <= 1;
            end
        endtask

    endclass
    class slave_monitor extends uvm_monitor;
        `uvm_component_utils(slave_monitor)

        uvm_analysis_port #(master_trans) ap;
        virtual slave_intf slave_vif;
        master_trans tr;
        int i, payload_szie;

        function new(string name="slave_monitor", uvm_component parent);
            super.new(name, parent);
        endfunction 

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            ap = new("ap", this);
            if(!uvm_config_db#(virtual slave_intf)::get(this, "", "slave_vif", slave_vif))
                `uvm_fatal("set vif", "get slave vif failed!!!")
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            while(slave_vif.rst)begin
                @(slave_vif.cb_mon);
            end
            forever begin
                tr = master_trans::type_id::create("tr");
                do_monitor(tr);
            end
        endtask
        task do_monitor(master_trans tr);
             `uvm_info("TEST", "monitor", UVM_LOW)
             // header
            @(slave_vif.cb_mon iff (slave_vif.tx && slave_vif.credit))
            `uvm_info("TEST", "monitor1", UVM_LOW)
            tr.header = slave_vif.data;
            // size
            @(posedge slave_vif.cb_mon iff (slave_vif.tx && slave_vif.credit))
            payload_szie = slave_vif.data;
            // payload
            i = 0;
            while(i < payload_szie)begin
                @(slave_vif.cb_mon iff (slave_vif.tx && slave_vif.credit))
                tr.payload.push_back(slave_vif.data);
                i = i+1;
            end
            tr.print();
            ap.write(tr);
        endtask
    endclass

    class slave_agent extends uvm_agent ;
        `uvm_component_utils(slave_agent)
        slave_monitor slave_mon;
        slave_driver slave_drv;
        uvm_analysis_port #(master_trans) ap;
        function new(string name="slave_agent", uvm_component parent);
            super.new(name, parent);
        endfunction 

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            slave_mon = slave_monitor::type_id::create("slave_mon", this);
            slave_drv = slave_driver::type_id::create("slave_drv", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            ap = slave_mon.ap;
        endfunction
    endclass
endpackage  