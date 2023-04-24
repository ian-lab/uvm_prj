`ifndef MY_RECEIVER_SV
`define MY_RECEIVER_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "my_transaction.sv"

class rcv_monitor extends uvm_monitor;
    `uvm_component_utils(rcv_monitor);

    virtual my_intf rcv_vif;
    uvm_analysis_port #(my_trans) ap;
    my_trans tr;
    bit [159:0] hash;

    function new(string name="rcv_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap=new("ap",this);
        if(!uvm_config_db#(virtual my_intf)::get(this,"", "my_intf", rcv_vif))
            `uvm_fatal(get_type_name(),"virtual interface set failure!")
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
            @(posedge rcv_vif.clock);
            if (rcv_vif.ck_out_mon.valid_out == 1'b1) break;
        end
        tr.hash = rcv_vif.ck_out_mon.hash;
        `uvm_info(get_type_name(), $sformatf("output hash is 'h%16x", tr.hash), UVM_LOW)
    endtask 
endclass 

class rcv_agent extends uvm_agent;
    rcv_monitor mon;
    uvm_analysis_port #(my_trans) ap;
    
    `uvm_component_utils(rcv_agent)

    function new(string name="rcv_agent", uvm_component parent);
        super.new(name, parent);
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = rcv_monitor::type_id::create("mon",this);   
    endfunction
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        ap = mon.ap;
    endfunction

endclass 

`endif 