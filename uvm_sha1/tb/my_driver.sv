`ifndef MY_DRIVER_SV
`define MY_DRIVER_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "my_transaction.sv"

class my_sequencer extends uvm_sequencer #(my_trans);
    `uvm_component_utils(my_sequencer)
    function new(string name="my_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction 
endclass

class input_driver extends uvm_driver #(my_trans);
    `uvm_component_utils(input_driver)
    virtual my_intf in_vif;

    function new(string name="input_driver", uvm_component parent=null);
        super.new(name,parent);
    endfunction 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual my_intf)::get(this, " ", "my_intf", in_vif))
            `uvm_fatal(get_type_name(), "virtual interface set failure!")
    endfunction

    task main_phase(uvm_phase phase);
        while(in_vif.reset_n) begin
            in_vif.ck_in.data_in <= 64'd0;
            in_vif.ck_in.valid_in <= 1'b0;
            @(posedge in_vif.clock);
        end
        in_vif.ck_in.data_in <= 64'd0;
        in_vif.ck_in.valid_in <= 1'b0;
        @(posedge in_vif.reset_n);
        while(1) begin    
            seq_item_port.get_next_item(req);    
            do_driver(req);
            seq_item_port.item_done();
        end
    endtask

    task do_driver(my_trans tr);
        `uvm_info(get_type_name(), $sformatf("data length is %3d", tr.drv_len), UVM_LOW)
        foreach(tr.drv_data[i])begin
            `uvm_info(get_type_name(), $sformatf("data[%2d] is 'h%16x", i, tr.drv_data[i]), UVM_LOW)
        end

        while(!in_vif.reset_n)
            @(posedge in_vif.clock);
        wait(in_vif.ck_in.in_ready == 1'b1);
        @(posedge in_vif.clock);
        in_vif.ck_in.data_in <= tr.drv_len;
        in_vif.ck_in.valid_in <= 1'b1;
        @(posedge in_vif.clock);
        while(tr.drv_data.size > 0)  begin
            in_vif.ck_in.data_in <= tr.drv_data.pop_front();
            in_vif.ck_in.valid_in <= 1'b1;
            @(posedge in_vif.clock);
            while( in_vif.in_ready == 1'b0) begin
                in_vif.ck_in.valid_in <= 1'b0;
                @(posedge in_vif.clock);
            end 
        end
        in_vif.ck_in.valid_in <= 1'b0;
        in_vif.ck_in.data_in <= 64'd0;
        #100ns;  
        wait(in_vif.ck_in.valid_out == 1'b1);
    endtask 
endclass

class drv_monitor extends uvm_monitor;
    `uvm_component_utils(drv_monitor);

    virtual my_intf in_vif;
    uvm_analysis_port #(my_trans) ap;
    my_trans tr;
    bit [63:0] drv_data;
    bit [63:0] drv_len;
    int rcv_cnt;

    function new(string name="drv_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap=new("ap",this);
        if (!uvm_config_db#(virtual my_intf)::get(this,"", "my_intf", in_vif))
            `uvm_fatal(get_type_name(), "virtual interface set failure!")
    endfunction

    task main_phase(uvm_phase phase);
        while(1) begin
            tr = new("tr");
            collect_one_pkg(tr);
            ap.write(tr);
        end
    endtask 

    task collect_one_pkg(my_trans tr);
        while (1) begin
            @(posedge in_vif.clock);
            if (in_vif.ck_in_mon.valid_in != 1'b0) break;
        end
        tr.drv_len = in_vif.ck_in_mon.data_in;
        rcv_cnt = (tr.drv_len-1)/64 + 1;
        @(posedge in_vif.clock);  
        while(rcv_cnt > 0) begin
            tr.drv_data.push_back(in_vif.ck_in_mon.data_in);
            while( in_vif.ck_in_mon.in_ready == 1'b0)begin
                @(posedge in_vif.clock);
            end
            @(posedge in_vif.clock);  
            rcv_cnt = rcv_cnt - 1;
        end
    
        `uvm_info(get_type_name(), $sformatf("data length is %3d", tr.drv_len), UVM_LOW)
        foreach(tr.drv_data[i])begin
            `uvm_info(get_type_name(), $sformatf("data[%2d] is 'h%16x", i, tr.drv_data[i]), UVM_LOW)
        end
    endtask 
endclass 

class drv_agent extends uvm_agent;
    input_driver drv;
    drv_monitor mon;
    my_sequencer sqr;
    uvm_analysis_port #(my_trans) ap;
    
    `uvm_component_utils(drv_agent)

    function new(string name="drv_agent", uvm_component parent);
        super.new(name, parent);
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = input_driver::type_id::create("drv", this);
        mon = drv_monitor::type_id::create("mon",this);
        sqr = my_sequencer::type_id::create("sqr",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
        ap = mon.ap;
    endfunction

endclass 

`endif
