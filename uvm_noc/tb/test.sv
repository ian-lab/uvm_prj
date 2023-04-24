package noc_test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import noc_env_pkg::*;
    import master_pkg::*;
    import slave_pkg::*;


    class base_test_sequence extends uvm_sequence #(master_trans);
        `uvm_object_utils(base_test_sequence)
        master_trans tr;

        function new(string name="base_test_sequence");
            super.new(name);
        endfunction 

        virtual task body();
            repeat(10)
            `uvm_do_with(tr,{tr.drv_port == EAST;})
        endtask
    endclass


    class base_test extends uvm_test;
        
        `uvm_component_utils(base_test)

        noc_env env;

        function new(string name="base_test", uvm_component parent);
            super.new(name, parent);
        endfunction 

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = noc_env::type_id::create("env",this);
        endfunction

    task run_phase(uvm_phase phase);
        base_test_sequence seq;
        phase.raise_objection(this);
        seq = base_test_sequence::type_id::create("seq", this);
        seq.start(env.master_agt.master_sqr);
        #100000;
        phase.drop_objection(this);
    endtask 
    endclass 

endpackage
