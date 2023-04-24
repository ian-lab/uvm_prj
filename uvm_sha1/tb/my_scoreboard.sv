`ifndef MY_SCOREBOARD_SV
`define MY_SCOREBOARD_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "my_transaction.sv"

class my_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(my_scoreboard)
    uvm_blocking_get_port #(my_trans) rf_mdl_port;
    uvm_blocking_get_port #(my_trans) rcv_mon_port;
    my_trans get_expect, get_actual;
    my_trans tmp_trans;
    my_trans expect_queue[$];
    bit [63:0] drv_length;

    covergroup len_cov;
        coverpoint drv_length{
            bins len_1 = {[1:63]};
            bins len_2 = {64};
            bins len_3 = {[65:127]};
            bins len_4 = {[128:383]};
            bins len_5 = {384};
            bins len_6 = {[385:447]};
            bins len_7 = {448};
            bins len_8 = {[449:511]};
            bins len_9 = {512};
            bins len_10 = {[513:575]};
            bins len_11 = {[576:960]};
            bins len_12 = {[961:1023]};
            bins len_13 = {1024};
            bins len_14 = {[1025:1215]};
            bins len_15 = {[1215:2000]};
        }
    endgroup: len_cov

    function new(string name="my_scoreboard", uvm_component parent);
        super.new(name, parent);
        len_cov=new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rf_mdl_port = new("rf_mdl_port",this);
        rcv_mon_port = new("rcv_mon_port",this);
    endfunction

    task main_phase(uvm_phase phase);
        fork
            while(1)begin
                rf_mdl_port.get(get_expect);
                expect_queue.push_back(get_expect);
            end
            while(1)begin
                rcv_mon_port.get(get_actual);
                if(expect_queue.size() > 0)begin
                    tmp_trans = expect_queue.pop_front();
                    if(get_actual.hash != tmp_trans.hash)begin
                        `uvm_fatal(get_type_name(),$sformatf("compare failed, expected hash is 'h%40x, actual hash is 'h%40x,",tmp_trans.hash, get_actual.hash))
                    end
                    else begin
                        `uvm_info(get_type_name(), "COMPARE SUCCESSFUL!!!", UVM_LOW)
                    end
                end
                else begin
                    `uvm_fatal(get_type_name(),$sformatf("recived data from dut, but the expected que is empty!!!"))
                end
                drv_length = tmp_trans.drv_len;
                len_cov.sample();
            end
        join
    endtask 
endclass 

`endif 