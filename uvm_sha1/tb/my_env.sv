`ifndef MY_ENV_SV
`define MY_ENV_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "my_transaction.sv"
`include "my_driver.sv"
`include "my_receiver.sv"
`include "my_model.sv"
`include "my_scoreboard.sv"

class my_env extends uvm_env;
    `uvm_component_utils(my_env)
    drv_agent drv_agt;
    rcv_agent rcv_agt;
    my_model rf_model;
    my_scoreboard scb;
    
    uvm_tlm_analysis_fifo #(my_trans) drv2mdl_fifo;
    uvm_tlm_analysis_fifo #(my_trans) mdl2scb_fifo;
    uvm_tlm_analysis_fifo #(my_trans) rcv2scb_fifo;

    function new(string name="my_env", uvm_component parent);
        super.new(name, parent);
    endfunction 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_agt = drv_agent::type_id::create("drv_agent", this);
        rcv_agt = rcv_agent::type_id::create("rcv_agent", this);
        rf_model = my_model::type_id::create("rf_model",this);
        scb = my_scoreboard::type_id::create("scb", this);
        
        drv2mdl_fifo = new("agt2mdl_fifo", this);
        mdl2scb_fifo = new("mdl2scb_fifo", this);
        rcv2scb_fifo = new("rcv2scb_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv_agt.ap.connect(drv2mdl_fifo.analysis_export);
        rf_model.port.connect(drv2mdl_fifo.blocking_get_export);

        rf_model.ap.connect(mdl2scb_fifo.analysis_export);
        scb.rf_mdl_port.connect(mdl2scb_fifo.blocking_get_export);

        rcv_agt.ap.connect(rcv2scb_fifo.analysis_export);
        scb.rcv_mon_port.connect(rcv2scb_fifo.blocking_get_export);
    endfunction

endclass 


`endif 