`ifndef TEST_SV
`define TEST_SV

class base_test extends uvm_test;
    my_env env;
    `uvm_component_utils(base_test)

    function new(string name="base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env=my_env::type_id::create("env",this);
    endfunction

    task main_phase(uvm_phase phase);
        my_sequence seq;
        phase.raise_objection(this);
        seq = my_sequence::type_id::create("seq", this);
        seq.start(env.drv_agt.sqr);
        #500;
        phase.drop_objection(this);
    endtask //
endclass //base_test extends uvm_test


`endif 