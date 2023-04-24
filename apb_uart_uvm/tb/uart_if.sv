`timescale 1ns/1ps
`ifndef UART_IF_SV
`define UART_IF_SV

interface uart_intf(input clk);
    logic data;

    // clocking cb_drv @(posedge clk);
    //     default input #1ps output #1ps;
    //     output data;
    // endclocking : cb_drv

    // clocking cb_mon @(posedge clk);
    //     default input #1ps output #1ps;
    //     input data;
    // endclocking : cb_mon
endinterface

// interface uart_rx_intf(input clk);
//     logic data;

//     clocking cb_drv @(posedge clk);
//         default input #1ps output #1ps;
//         output data;
//     endclocking : cb_drv
//     clocking cb_mon @(posedge clk);
//         default input #1ps output #1ps;
//         input data;
//     endclocking : cb_mon
// endinterface

// interface uart_tx_intf(input clk);
//     logic data;

//     clocking cb_mon @(posedge clk);
//         default input #1ps output #1ps;
//         input data;
//     endclocking : cb_mon
// endinterface

interface irq_intf(input clk);
    logic irq;
    logic baud_out;
    clocking cb_mon @(posedge clk);
        default input #1ps output #1ps;
        input irq,baud_out;
    endclocking : cb_mon
endinterface

interface modem_intf(input clk);
    logic nCTS;
    logic nDSR;
    logic nDCD;
    logic nRI;
    logic nRTS;
    logic nDTR;
    logic OUT1;
    logic OUT2;
    clocking cb_drv @(posedge clk);
        default input #1ps output #1ps;
        output nCTS,nDSR,nDCD,nRI;
    endclocking : cb_drv

    clocking cb_mon @(posedge clk);
        default input #1ps output #1ps;
        input nCTS,nDSR,nDCD,nRI,nRTS,nDTR,OUT1,OUT2;
    endclocking : cb_mon
endinterface 

`endif
