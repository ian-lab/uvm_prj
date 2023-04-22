`ifndef MY_SEQUENCE_SV
`define MY_SEQUENCE_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "my_transaction.sv"

class my_sequence extends uvm_sequence #(my_trans);
    my_trans m_trans;
    `uvm_object_utils(my_sequence)
    function new(string name="my_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        // `uvm_do(m_trans)
        `uvm_do_with(m_trans, {drv_len == 63;})
        `uvm_do_with(m_trans, {drv_len == 64;})
        `uvm_do_with(m_trans, {drv_len == 65;})
        `uvm_do_with(m_trans, {drv_len == 127;})
        `uvm_do_with(m_trans, {drv_len == 128;})
        `uvm_do_with(m_trans, {drv_len == 129;})
        `uvm_do_with(m_trans, {drv_len == 447;})
        `uvm_do_with(m_trans, {drv_len == 448;})
        `uvm_do_with(m_trans, {drv_len == 449;})
        `uvm_do_with(m_trans, {drv_len == 511;})
        `uvm_do_with(m_trans, {drv_len == 512;})
        `uvm_do_with(m_trans, {drv_len == 513;})
        `uvm_do_with(m_trans, {drv_len == 1023;})
        `uvm_do_with(m_trans, {drv_len == 1024;})
        `uvm_do_with(m_trans, {drv_len == 1025;})
        `uvm_do_with(m_trans, {drv_len == 2047;})
        `uvm_do_with(m_trans, {drv_len == 2048;})
        `uvm_do_with(m_trans, {drv_len == 2049;})
        repeat(1000)begin
            `uvm_do(m_trans)
        end 
    endtask 
endclass 

`endif 