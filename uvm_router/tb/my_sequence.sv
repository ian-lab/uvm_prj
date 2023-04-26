`ifndef MY_SEQUENCE_SV
`define MY_SEQUENCE_SV

class my_sequence extends uvm_sequence #(my_trans);
    my_trans m_trans;
    `uvm_object_utils(my_sequence)
    function new(string name="my_sequence");
        super.new(name);
    endfunction //new()

    virtual task body();
        repeat(5000)begin
            `uvm_do(m_trans)
        end 
    endtask 
endclass //my_sequece extends uvm_sequence

`endif 