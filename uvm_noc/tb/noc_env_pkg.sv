package noc_env_pkg;
    import master_pkg::*;
    import slave_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"




    class noc_env extends uvm_env;
        `uvm_component_utils(noc_env)

        master_agent master_agt;
        slave_agent slave_agt;
        function new(string name="noc_env", uvm_component parent);
            super.new(name, parent);
        endfunction 

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            master_agt = master_agent::type_id::create("master_agt", this);
            slave_agt = slave_agent::type_id::create("slave_agt", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
        endfunction
    endclass

endpackage