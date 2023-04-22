import uvm_pkg::*;
import fifo_test_pkg::*;
`include "uvm_macros.svh"
`include "fifo_if.sv"
class clk_period;
    rand int wr_period;
    rand int rd_period;
    constraint per{
        wr_period inside{10,20,30};
        rd_period inside{10,20,30};
    }
endclass

module tb();
    reg wclk;
    reg rclk;
    reg wrstn;
    reg rrstn;
    fifo_intf wr_if(wclk, wrstn);
    fifo_intf rd_if(rclk, rrstn);

fifo_top du(
	.write(wr_if.en), 
    .wreset_b(wrstn), 
    .wclk(wclk), 
    .read(rd_if.en), 
    .rreset_b(rrstn), 
    .rclk(rclk),
	.wdata(wr_if.data),
	.rdata(rd_if.data),
	.rempty(rd_if.valid),
    .wfull(wr_if.valid)
);


int wr_period = 20;
int rd_period = 10;
initial begin
    clk_period clk_per;
    clk_per = new();
    void'(clk_per.randomize());
    `uvm_info("clk_period", $sformatf("wr_clk period is %00d, rd_clk period is %00d",clk_per.wr_period, clk_per.rd_period), UVM_LOW)
    wclk = 0; 
    rclk = 0; 
    fork
        forever #clk_per.wr_period wclk = ~wclk;
        forever #clk_per.rd_period rclk = ~rclk;
    join
end

initial begin
    wrstn = 0;  rrstn = 0;
    #50 wrstn = 1; rrstn=1;
end

initial begin
    uvm_config_db#(virtual fifo_intf)::set(uvm_root::get(), "uvm_test_top.env.fifo_wr_agt*", "fifo_vif", wr_if);
    uvm_config_db#(virtual fifo_intf)::set(uvm_root::get(), "uvm_test_top.env.fifo_rd_agt*", "fifo_vif", rd_if);   
    uvm_config_db#(virtual fifo_intf)::set(uvm_root::get(), "uvm_test_top.env.fifo_ref*", "fifo_wr_vif", wr_if);
    uvm_config_db#(virtual fifo_intf)::set(uvm_root::get(), "uvm_test_top.env.fifo_ref*", "fifo_rd_vif", rd_if);  
    run_test("base_test");
end

endmodule