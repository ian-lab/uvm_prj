`ifndef MY_RECEIVER_SV
`define MY_RECEIVER_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "my_transaction.sv"
class rcv_monitor extends uvm_monitor;
    `uvm_component_utils(rcv_monitor);

    virtual rcv_intf rcv_vif;
    uvm_analysis_port #(my_trans) ap;
    my_trans tr;
    bit [3:0] rcv_id;
    bit [7:0] payload;

    function new(string name="rcv_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap=new("ap",this);
        if(!uvm_config_db#(virtual rcv_intf)::get(this,"", "rcv_intf", rcv_vif))
            `uvm_fatal(get_type_name(),"virtual interface set failure!")
        else
            `uvm_info(get_type_name(),"virtual interface set successful!", UVM_LOW)
    endfunction

    task main_phase(uvm_phase phase);
        while(1) begin
            tr = new("tr");
            collect_one_pkg(tr);
            ap.write(tr);
        end
    endtask //

    task collect_one_pkg(my_trans tr);
        while (1) begin
            @(posedge rcv_vif.clock);
            if (rcv_vif.ck_mon.frameo_n != 16'hffff)break;
        end
        case (rcv_vif.ck_mon.frameo_n)
            16'hfffe: rcv_id = 4'd0; 16'hfffd: rcv_id = 4'd1; 16'hfffb: rcv_id = 4'd2; 16'hfff7: rcv_id = 4'd3;
            16'hffef: rcv_id = 4'd4; 16'hffdf: rcv_id = 4'd5; 16'hffbf: rcv_id = 4'd6; 16'hff7f: rcv_id = 4'd7;
            16'hfeff: rcv_id = 4'd8; 16'hfdff: rcv_id = 4'd9; 16'hfbff: rcv_id = 4'd10;16'hf7ff: rcv_id = 4'd11;
            16'hefff: rcv_id = 4'd12;16'hdfff: rcv_id = 4'd13;16'hbfff: rcv_id = 4'd14;16'h7fff: rcv_id = 4'd15;
            default: rcv_id = 0;
        endcase
        tr.rcv_id=rcv_id;

        wait (rcv_vif.ck_mon.valido_n[rcv_id] == 1'b0);
        @(posedge rcv_vif.clock);

        for(int i=0; i<8; i++)begin
            payload[i] = rcv_vif.ck_mon.dout[rcv_id];
            @(posedge rcv_vif.clock);
        end
        tr.payload = payload;
        
        `uvm_info(get_type_name(),$sformatf("rcv_id is 'h%8x, payload is 'h%8x", tr.rcv_id, tr.payload), UVM_LOW)
    endtask //
endclass //rcv_monitor extends uvm_monitor

class rcv_agent extends uvm_agent;
    rcv_monitor mon;
    uvm_analysis_port #(my_trans) ap;
    
    `uvm_component_utils(rcv_agent)

    function new(string name="rcv_agent", uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = rcv_monitor::type_id::create("mon",this);   
    endfunction
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        ap = mon.ap;
    endfunction

endclass //rcv_agent extends uvm_agent

`endif 