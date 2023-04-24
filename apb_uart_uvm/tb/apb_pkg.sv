package apb_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
// `include "apb_if.sv"
typedef enum { IDLE, WRITE, READ } apb_trans_kind;
class apb_trans extends uvm_sequence_item;
    rand bit [31:0] data;
    rand bit [31:0] addr;
    rand apb_trans_kind trans_kind;

    `uvm_object_utils_begin(apb_trans)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_enum(apb_trans_kind, trans_kind, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="apb_trans");
        super.new(name);
    endfunction 
endclass 

class apb_config extends uvm_object;
    `uvm_object_utils(apb_config)
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    function new(string name="apb_config");
        super.new(name);
    endfunction 
endclass 

class apb_sequencer extends uvm_sequencer #(apb_trans);
    `uvm_component_utils(apb_sequencer)
    function new(string name="apb_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction 
endclass 

class apb_driver extends uvm_driver  #(apb_trans);
    `uvm_component_utils(apb_driver)
    virtual apb_intf apb_vif;
    function new(string name="apb_driver", uvm_component parent);
        super.new(name, parent);
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_vif", apb_vif))
            `uvm_fatal("set vif", "Virtual Interface Set failed")
    endfunction

    task run_phase(uvm_phase phase);
        send_pkg();
    endtask 

    task send_pkg();
        forever begin
            seq_item_port.get_next_item(req);
            case(req.trans_kind)
                IDLE: do_idle();
                WRITE: do_write(req);
                READ: do_read(req);
            endcase
            seq_item_port.item_done();
        end
    endtask

    task do_idle();
        @(apb_vif.cb_drv);
        apb_vif.cb_drv.psel <= 1'b0;
        apb_vif.cb_drv.penable <= 1'b0;
        apb_vif.cb_drv.pwdata <= 1'b0;
    endtask 

    task do_write(apb_trans tr);
        @(apb_vif.cb_drv);
        apb_vif.cb_drv.paddr <= tr.addr;
        apb_vif.cb_drv.pwdata <= tr.data;
        apb_vif.cb_drv.pwrite <= 1'b1;
        apb_vif.cb_drv.psel <= 1'b1;
        apb_vif.cb_drv.penable <= 1'b0;
        @(apb_vif.cb_drv);
        apb_vif.cb_drv.penable <= 1'b1;   
        wait(apb_vif.pready === 1'b1);
        if(apb_vif.pslverr === 1'b1)begin
            `uvm_error("apb trans", "apb write error")
        end
        #10ps;
        do_idle();  
    endtask 

    task do_read(apb_trans tr);
        @(apb_vif.cb_drv);
        apb_vif.cb_drv.paddr <= tr.addr;
        apb_vif.cb_drv.pwrite <= 0;
        apb_vif.cb_drv.psel <= 1;
        apb_vif.cb_drv.penable <= 0;
        @(apb_vif.cb_drv);
        apb_vif.cb_drv.penable <= 1;
        wait(apb_vif.pready === 1);
        if(apb_vif.pslverr === 1'b1)begin
            `uvm_error("apb trans", "apb read error")
        end
        tr.data = apb_vif.cb_drv.prdata;
        #10ps;
        do_idle();  
    endtask 
endclass 

class apb_monitor extends uvm_monitor ;
    `uvm_component_utils(apb_monitor)
    uvm_analysis_port #(apb_trans) ap;
    virtual apb_intf apb_vif;
    apb_trans tr;
     
    function new(string name="apb_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction 

    function void build_phase(uvm_phase phase);
        tr = new("tr");
        if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_vif", apb_vif))
            `uvm_fatal("get vif", "get vif failed")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            collect_trans();
            ap.write(tr);
        end
    endtask 

    task collect_trans();
            while(!(apb_vif.cb_mon.psel === 1 && apb_vif.cb_mon.penable === 0))
                @(apb_vif.cb_mon);
            wait(apb_vif.pready === 1'b1);
            @(apb_vif.cb_mon);
            case(apb_vif.cb_mon.pwrite)
                1'b1 : begin 
                    tr.addr = apb_vif.cb_mon.paddr;
                    tr.data = apb_vif.cb_mon.pwdata;
                    tr.trans_kind = WRITE;
                end
                1'b0 : begin 
                    tr.addr = apb_vif.cb_mon.paddr;
                    tr.data = apb_vif.cb_mon.prdata;
                    tr.trans_kind = READ;
                end
            endcase
    endtask
endclass 

class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)

    uvm_analysis_port #(apb_trans) ap;
    apb_driver drv;
    apb_monitor mon;
    apb_sequencer sqr;
    apb_config cfg;

    function new(string name = "apb_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        mon=apb_monitor::type_id::create("mon", this);
        if(!uvm_config_db #(apb_config)::get(this,"", "apb_cfg", cfg))
            `uvm_fatal("get cfg","get conifg failed");
        if(cfg.is_active) begin
            drv=apb_driver::type_id::create("drv",this);
            sqr=apb_sequencer::type_id::create("sqr",this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        ap = mon.ap;
        if(cfg.is_active)begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction
endclass

endpackage
