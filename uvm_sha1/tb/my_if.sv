`ifndef MY_IF_SV
`define MY_IF_SV

interface my_intf(input clock, input reset_n);
    logic [63:0]  data_in;
    logic         valid_in;
    logic         in_ready;
    logic [159:0] hash;
    logic         valid_out;
    
    clocking ck_in @(posedge clock);
        default input #1ns output #1ns;
        output data_in, valid_in;
        input in_ready, valid_out;
    endclocking:ck_in

    clocking ck_in_mon  @(posedge clock);
        default input #1ns output #1ns;
        input data_in, valid_in, in_ready;
    endclocking:ck_in_mon

    clocking ck_out_mon  @(posedge clock);
        default input #1ns output #1ns;
        input hash, valid_out;
    endclocking:ck_out_mon

endinterface 


`endif