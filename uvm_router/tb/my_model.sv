`ifndef MY_MODEL_SV
`define MY_MODEL_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "my_transaction.sv"
class my_model extends uvm_component;
    `uvm_component_utils(my_model)

    uvm_blocking_get_port #(my_trans) port;
    uvm_analysis_port #(my_trans) ap;

    function new(string name="my_model", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        port = new("port",this);
        ap = new("ap",this);
    endfunction

    task main_phase(uvm_phase phase);
        my_trans tr;
        my_trans new_tr;
        super.main_phase(phase);
        while(1) begin
            port.get(tr);
            // `uvm_info(get_type_name(),$sformatf("drv_id is 'h%8x,rcv_id is 'h%8x, payload is 'h%8x", tr.drv_id, tr.rcv_id, tr.payload), UVM_LOW)
            new_tr = new("new_tr");
            new_tr.copy(tr);
            ap.write(new_tr);
        end
    endtask 
endclass 

`endif 