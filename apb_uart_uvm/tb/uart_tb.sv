`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_uart_test::*;
`include "apb_if.sv"
`include "uart_if.sv"

module uart_tb();
    reg pclk;
    reg rstn;
    logic baud_o;

    apb_intf apb_if(pclk, rstn);
    irq_intf irq_if(pclk);
    uart_intf uart_tx(irq_if.baud_out);
    uart_intf uart_rx(irq_if.baud_out);
    
    modem_intf modem_if(pclk);

    uart_16550 DUT (
        // APB 
        .PCLK       (pclk       ),
        .PRESETn    (rstn       ),
        .PADDR      (apb_if.paddr  ),
        .PWDATA     (apb_if.pwdata ),
        .PRDATA     (apb_if.prdata ),
        .PWRITE     (apb_if.pwrite ),
        .PENABLE    (apb_if.penable),
        .PSEL       (apb_if.psel   ),
        .PREADY     (apb_if.pready ),
        .PSLVERR    (apb_if.pslverr),
        // UART signals
        .TXD        (uart_tx.data),
        .RXD        (uart_rx.data),
        // interrupt
        .IRQ        (irq_if.irq ),
        // Baud rate generator output
        .baud_o    (irq_if.baud_out),
        // modem signals
        .nRTS       (modem_if.nRTS ),
        .nDTR       (modem_if.nDTR ),
        .nOUT1      (modem_if.OUT1),
        .nOUT2      (modem_if.OUT2),
        .nCTS       (modem_if.nCTS ),
        .nDSR       (modem_if.nDSR ),
        .nDCD       (modem_if.nDCD ),
        .nRI        (modem_if.nRI  )       
    );

    initial begin
        pclk = 0;
        forever #5 pclk = ~pclk;
    end

    initial begin
        rstn=0;
        #50 rstn = 1;
    end

    initial begin
        uvm_config_db#(virtual apb_intf)::set(uvm_root::get(),   "uvm_test_top.env*",             "apb_vif",   apb_if);
        uvm_config_db#(virtual irq_intf)::set(uvm_root::get(),   "uvm_test_top.env*",             "irq_vif",   irq_if);
        uvm_config_db#(virtual modem_intf)::set(uvm_root::get(), "uvm_test_top.env*",             "modem_vif", modem_if);
        uvm_config_db#(virtual uart_intf)::set(uvm_root::get(),  "uvm_test_top.env.uart_rx_agt*", "uart_vif",  uart_rx);
        uvm_config_db#(virtual uart_intf)::set(uvm_root::get(),  "uvm_test_top.env.uart_tx_agt*", "uart_vif",  uart_tx);
        run_test();
    end

endmodule