`ifndef FIFO_IF_SV
`define FIFO_IF_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
interface fifo_intf(input clk, input rstn);
    logic [31:0] data;
    logic        en;
    logic        valid;

endinterface


`endif