`ifndef MY_TRANSACTION_SV
`define MY_TRANSACTION_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class my_trans extends uvm_sequence_item;
        rand bit [63:0] drv_data [$];
        rand bit [63:0] drv_len;
        bit [159:0] hash;

        constraint cstr{
            soft drv_len inside {[1:2000]};
            drv_data.size() == (drv_len-1)/64+1;
            // soft drv_len==8;
            // drv_data.size() == (drv_len-1)/64+1;
        }

        `uvm_object_utils_begin(my_trans)
            `uvm_field_queue_int(drv_data, UVM_ALL_ON)
            `uvm_field_int(drv_len, UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name="my_trans");
            super.new(name);
        endfunction 

endclass 

`endif