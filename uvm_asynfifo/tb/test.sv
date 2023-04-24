package fifo_test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import fifo_pkg::*;

    class wr_sequence extends uvm_sequence #(uvm_sequence_item);
        `uvm_object_utils(wr_sequence)
        fifo_trans fifo_tr;
        rand int data_size;
        constraint size{
            soft data_size == 1;
        }

        function new(string name="wr_sequence");
            super.new(name);
        endfunction

        virtual task body();
            // data_size = 1;
            `uvm_do_with(fifo_tr, {fifo_tr.data.size == local::data_size;})
        endtask
    endclass

    class rd_sequence extends uvm_sequence #(uvm_sequence_item);
        `uvm_object_utils(rd_sequence)
        fifo_trans fifo_tr;
        rand int data_size;

        function new(string name="rd_sequence");
            super.new(name);
        endfunction

        virtual task body();
            data_size = 1;
            `uvm_do_with(fifo_tr, {fifo_tr.data.size == local::data_size;})
        endtask
    endclass

    class base_test_sequence extends uvm_sequence #(uvm_sequence_item);
        `uvm_object_utils(base_test_sequence)
        fifo_sequencer wr_sqr;
        fifo_sequencer rd_sqr;
        wr_sequence wr_seq;
        rd_sequence rd_seq;
        int wr_num;

        function new(string name="base_test_sequence");
            super.new(name);
        endfunction

        task body();
            int i;
            int j;
            wr_num = 500;
            
            i=0;
            j=0;
            fork
                begin
                    repeat(wr_num)begin 
                        `uvm_do_on_with(wr_seq, wr_sqr, {wr_seq.data_size==1;})
                        `uvm_info("test",$sformatf("write[%0d]", i), UVM_LOW) 
                        i+=1; 
                    end
                end
                begin
                    repeat(wr_num) begin
                        `uvm_do_on(rd_seq, rd_sqr)
                        `uvm_info("test",$sformatf("read[%0d]", j), UVM_LOW) 
                        j+=1; 
                    end
                    `uvm_info("test","end read", UVM_LOW)
                end
            join
        endtask
    endclass


    class base_test extends uvm_test;
        `uvm_component_utils(base_test)
        
        fifo_env env;
        base_test_sequence base_seq;

        function new(string name="base_test", uvm_component parent);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            env = fifo_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            base_seq = base_test_sequence::type_id::create("base_seq", this);
            base_seq.wr_sqr = env.fifo_wr_agt.fifo_sqr;
            base_seq.rd_sqr = env.fifo_rd_agt.fifo_sqr;
            base_seq.start(null);
            #100ns;
            phase.drop_objection(this);
        endtask
    endclass
endpackage