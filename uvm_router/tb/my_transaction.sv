`ifndef MY_TRANSACTION_SV
`define MY_TRANSACTION_SV

class my_trans extends uvm_sequence_item;
        rand bit [3:0] drv_id;
        rand bit [3:0] rcv_id;
        rand bit [7:0] payload;
        bit rsp;

        constraint cstr{
            soft payload inside {[0:255]};
            soft drv_id inside {[0:15]};
            soft rcv_id inside {[0:15]};
        }

        `uvm_object_utils_begin(my_trans)
            `uvm_field_int(payload, UVM_ALL_ON)
            `uvm_field_int(drv_id, UVM_ALL_ON)
            `uvm_field_int(rcv_id, UVM_ALL_ON)
            `uvm_field_int(rsp, UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name="my_trans");
            super.new(name);
        endfunction 

endclass //my_trans extends uvm_sequence_item


`endif