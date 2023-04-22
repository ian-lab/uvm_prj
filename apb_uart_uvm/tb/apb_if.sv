`timescale 1ns/1ps
`ifndef APB_IF_SV
`define APB_IF_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
interface apb_intf (input clk, input rstn);

    logic [31:0] paddr;
    logic        pwrite;
    logic        psel;
    logic        penable;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic        pready;
    logic        pslverr;

    clocking cb_drv @(posedge clk);
        default input #1ps output #1ps;
        output paddr, pwrite, psel, penable, pwdata;
        input prdata, pready, pslverr;
    endclocking : cb_drv

    clocking cb_mon @(posedge clk);
        default input #1ps output #1ps;
        input paddr, pwrite, psel, penable, pwdata, prdata, pready, pslverr;
    endclocking : cb_mon

    property penable_rose_after_psel_rose;
        @(posedge clk) $rose(psel) |=>  $rose(penable); 
    endproperty
    assert property(penable_rose_after_psel_rose) 
    else `uvm_error("ASSERT", "PENABLE not rose after PSEL rose")

    property penable_fell_after_pready;
        @(posedge clk) penable && pready |=>  $fell(penable); 
    endproperty
    assert property(penable_fell_after_pready) 
    else `uvm_error("ASSERT", "PENABLE not fell after pready rose")

    property pwdata_stable_during_trans;
        @(posedge clk) (psel && !penable) |=> $stable(pwdata);
    endproperty: pwdata_stable_during_trans
    assert property(pwdata_stable_during_trans) 
    else `uvm_error("ASSERT", "PWDATA not stable during transaction")
    
    property paddr_stable_during_trans;
        @(posedge clk) (psel && !penable) |=> $stable(paddr);
    endproperty: paddr_stable_during_trans
    assert property(paddr_stable_during_trans) 
    else `uvm_error("ASSERT", "PADDR not stable during transaction")
    
    property pwrite_stable_during_trans;
        @(posedge clk) (psel && !penable) |=> $stable(pwrite);
    endproperty: pwrite_stable_during_trans
    assert property(pwrite_stable_during_trans) 
    else `uvm_error("ASSERT", "PWRITE not stable during transaction")


endinterface




`endif