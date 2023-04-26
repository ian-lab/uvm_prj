package drv_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class drv_trans extends uvm_sequence_item;
        rand bit [3:0] drv_id;
        rand bit [3:0] rcv_id;
        rand bit [7:0] payload[];
        bit rsp;

        constraint cstr{
            soft payload.size inside {[1:10]};
            soft drv_id inside {[0:15]};
            soft rcv_id inside {[0:15]};
        }

        `uvm_object_utils_begin(drv_trans)
            `uvm_field_array_int(payload, UVM_ALL_ON)
            `uvm_field_int(drv_id, UVM_ALL_ON)
            `uvm_field_int(rcv_id, UVM_ALL_ON)
            `uvm_field_int(rsp, UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name="drv_trans");
            super.new(name);
        endfunction //new()

    endclass //drv_trans


    class drv_sequencer extends uvm_sequencer #(drv_trans);
        `uvm_component_utils(drv_sequencer)
        function new(string name="drv_sequencer", uvm_component parent);
            super.new(name, parent);
        endfunction //new()
    endclass //

    class drv_sequence extends uvm_sequence #(drv_trans);
        `uvm_object_utils(drv_sequence)
        drv_trans m_trans;
        function new(string name="drv_sequence");
           super.new(name);
        endfunction //new()

        task body();
            repeat(10) `uvm_do(m_trans)
            `uvm_info(get_type_name(), m_trans.sprint(),UVM_HIGH)
        endtask //

   endclass //drv_sequence extends superClass

    class drv_driver extends uvm_driver;
        local virtual drv_intf intf;
        `uvm_component_utils(drv_driver)

        function new(string name="drv_driver", uvm_component parent);
           super.new(name, parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            `uvm_info(get_type_name(),"drv_driver build phase",UVM_HIGH  )
            if(!uvm_config_db#(virtual drv_intf)::get(this,"", "dvr_if",intf))
                `uvm_fatal(get_type_name(),"virtual interface set failure!")
            else
                `uvm_info(get_type_name(),"virtual interface set successful!",UVM_HIGH  )
        endfunction //

        task run_phase(uvm_phase phase);
            fork
                this.do_driver();
            join
        endtask //automatic

        task do_driver();
            drv_trans req;
            @(posedge intf.reset_n);
            // seq_item_port.get_next_item()
            intf.frame_n <= 1;
            intf.frame_n <= 1;
            intf.din <= 1;
            `uvm_info(get_type_name(),"data is drived",UVM_HIGH)
        endtask //

    endclass //driver extends superClass

endpackage : drv_pkg