`timescale 1ns/1ps
`include "noc_if.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"
import noc_env_pkg::*;
import noc_test_pkg::*;
module tb();
    logic clk;
    logic rst;

    master_intf master_if[5](clk, rst);
    slave_intf  slave_if [5](clk, rst);

    logic [4:0] clock_rx, rx, credit_o;
    logic [15:0] data_in[4:0];

    logic [4:0] clock_tx, tx, credit_i;
    logic [15:0] data_out[4:0];


    initial begin
        clk = 0;   
        forever #10 clk = !clk;
    end
    initial begin
        rst = 1'b1;
        #20 rst = 1'b0;
    end
    initial begin
        uvm_config_db#(virtual master_intf)::set(null,"*","master_vif", master_if[0]);
        uvm_config_db#(virtual slave_intf)::set(null,"*","slave_vif", slave_if[4]);
        run_test("base_test");
    end
    generate
    	for (genvar i = 0; i < 5; i++) begin
    		// input port
    		assign clock_rx[i]          = clk;
    		assign rx[i]                = master_if[i].rx;
    		assign master_if[i].credit  = credit_o[i];
    		assign data_in[i]           = master_if[i].data;
    		// output port
    		assign slave_if[i].tx_clk   = clock_tx[i];
    		assign slave_if[i].tx       = tx[i];
    		// assign credit_i[i]          = slave_if[i].credit;
            
            assign credit_i[i]          = 1'b1;
    		assign slave_if[i].data     = data_out[i];
    	end
     endgenerate

    RouterCC #(
        .address(8'h11)
    ) CC ( 
        .clock(clk), 
        .reset(rst),
    	.clock_rx(clock_rx),
    	.rx(rx),
    	.data_in(data_in),
    	.credit_o(credit_o),

    	.clock_tx(clock_tx),
    	.tx(tx),
    	.data_out(data_out),
    	.credit_i(credit_i)
    	);





endmodule