`timescale 1ns/1ps
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

module tb_router;
    logic clock;
    logic reset_n;

    drv_intf drv_if(clock, reset_n);
    rcv_intf rcv_if(clock, reset_n);
    
    router  u_router (
    .reset_n   ( reset_n    ),
    .clock     ( clock      ),
    .din       ( drv_if.din        ),
    .frame_n   ( drv_if.frame_n    ),
    .valid_n   ( drv_if.valid_n    ),

    .dout      ( rcv_if.dout       ),
    .valido_n  ( rcv_if.valido_n   ),
    .busy_n    ( drv_if.busy_n     ),
    .frameo_n  ( rcv_if.frameo_n   )
    );

    initial begin
        clock = 0;
        forever #100 clock = ~clock;
    end

    initial begin
        reset_n = 1'b0;
        #1000;
        reset_n = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual drv_intf)::set(null, "uvm_test_top.env.drv_agent.drv", "drv_intf", drv_if);
        uvm_config_db#(virtual drv_intf)::set(null, "uvm_test_top.env.drv_agent.mon", "drv_intf", drv_if);
        uvm_config_db#(virtual rcv_intf)::set(null, "uvm_test_top.env.rcv_agent.mon", "rcv_intf", rcv_if);
        run_test("base_test");
    end
  
endmodule