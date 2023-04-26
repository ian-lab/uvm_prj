`ifndef MY_IF_SV
`define MY_IF_SV

interface drv_intf(input clock, input reset_n);
    logic [15:0] frame_n;
    logic [15:0] valid_n;
    logic [15:0] din;
    logic [15:0] busy_n;

    clocking ck_drv @(posedge clock);
        default input #1ns output #1ns;
        output frame_n, din, valid_n;
        input busy_n;
    endclocking:ck_drv

    clocking ck_mon  @(posedge clock);
        default input #1ns output #1ns;
        input din, frame_n, valid_n, busy_n;
    endclocking:ck_mon
endinterface //router

interface rcv_intf(input clock, input reset_n);
    logic [15:0] dout;
    logic [15:0] valido_n;
    logic [15:0] frameo_n;

    clocking ck_mon  @(posedge clock);
        default input #1ns output #1ns;
        input dout, valido_n, frameo_n;
    endclocking:ck_mon
endinterface //router

`endif