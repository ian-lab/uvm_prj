// `timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "my_if.sv"
`include "my_transaction.sv"
`include "my_driver.sv"
`include "my_receiver.sv"
`include "my_model.sv"
`include "my_scoreboard.sv"
`include "my_env.sv"
`include "my_sequence.sv"
`include "test.sv"

module tb_sha_1;
    logic clock;
    logic reset_n;

    my_intf my_if(clock, reset_n);

    sha_1  u_sha_1 (
        .clk        ( clock         ),
        .rst_n      ( reset_n       ),
        .data_in    ( my_if.data_in     ),
        .valid_in   ( my_if.valid_in    ),

        .hash       ( my_if.hash        ),
        .valid_out  ( my_if.valid_out   ),
        .in_ready   ( my_if.in_ready    )
    );

    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    initial begin
        reset_n = 1'b1;
        #50;
        reset_n = 1'b0;
        #50;
        reset_n = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual my_intf)::set(null, "uvm_test_top.env.drv_agent*", "my_intf", my_if);
        uvm_config_db#(virtual my_intf)::set(null, "uvm_test_top.env.rcv_agent*", "my_intf", my_if);
        run_test("base_test");
    end
    initial begin
		$fsdbDumpfile("tb.fsdb");
		$fsdbDumpvars(0,tb_sha_1);
	end
  
endmodule


