`ifndef MY_DRIVER_SV
`define MY_DRIVER_SV

class my_sequencer extends uvm_sequencer #(my_trans);
    `uvm_component_utils(my_sequencer)
    function new(string name="my_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction //new()
endclass //my_sequencer extends superClass

class drv_driver extends uvm_driver #(my_trans);
    `uvm_component_utils(drv_driver)
    virtual drv_intf drv_vif;

    function new(string name="drv_driver", uvm_component parent=null);
        super.new(name,parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual drv_intf)::get(this,"", "drv_intf",drv_vif))
            `uvm_fatal(get_type_name(),"virtual interface set failure!")
        else
            `uvm_info(get_type_name(),"virtual interface set successful!", UVM_LOW)
    endfunction

    task main_phase(uvm_phase phase);
        // phase.raise_objection(this);
        while(!drv_vif.reset_n) begin
            drv_vif.ck_drv.din <= 16'd0;
            drv_vif.ck_drv.frame_n <= 16'hffff;
            drv_vif.ck_drv.valid_n <= 16'hffff;
            @(posedge drv_vif.clock);
        end
                 
        while(1) begin
            seq_item_port.get_next_item(req);
            do_driver(req);
            seq_item_port.item_done();
        end
        // phase.drop_objection(this);
    endtask //

    task do_driver(my_trans tr);
        `uvm_info(get_type_name(),$sformatf("drv_id is 'h%8x,rcv_id is 'h%8x, payload is 'h%8x", tr.drv_id, tr.rcv_id, tr.payload), UVM_LOW)
        
        while(!drv_vif.reset_n)
            @(posedge drv_vif.clock);

        @(posedge drv_vif.clock);
        drv_vif.ck_drv.frame_n[tr.drv_id] <= 1'b0;

        for(int i=0; i<4; i++)begin
            drv_vif.ck_drv.din[tr.drv_id] <= tr.rcv_id[i];
            @(posedge drv_vif.clock);
        end

        drv_vif.ck_drv.din[tr.drv_id] <= 1'b1;
        drv_vif.ck_drv.valid_n[tr.drv_id] <=1'b1;
        repeat(5) @(posedge drv_vif.clock);
        
        for(int i=0; i<8; i++)begin
            drv_vif.ck_drv.din[tr.drv_id] <= tr.payload[i];
            drv_vif.ck_drv.valid_n[tr.drv_id] <= 1'b0;
            drv_vif.ck_drv.frame_n[tr.drv_id] <= (i == 7);
            @(posedge drv_vif.clock);
        end
        drv_vif.ck_drv.valid_n[tr.drv_id] <=1'b1;  
        #100ns;  
    endtask 

endclass // extends superClass


class drv_monitor extends uvm_monitor;
    `uvm_component_utils(drv_monitor);

    virtual drv_intf drv_vif;
    uvm_analysis_port #(my_trans) ap;
    my_trans tr;
    bit [3:0] rcv_id;
    bit [3:0] drv_id;
    bit [7:0] payload;

    function new(string name="drv_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap=new("ap",this);
        if(!uvm_config_db#(virtual drv_intf)::get(this,"", "drv_intf",drv_vif))
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
            @(posedge drv_vif.clock);
            if (drv_vif.ck_mon.frame_n != 16'hffff)break;
        end
        case (drv_vif.ck_mon.frame_n)
            16'hfffe: drv_id = 4'd0; 16'hfffd: drv_id = 4'd1; 16'hfffb: drv_id = 4'd2; 16'hfff7: drv_id = 4'd3;
            16'hffef: drv_id = 4'd4; 16'hffdf: drv_id = 4'd5; 16'hffbf: drv_id = 4'd6; 16'hff7f: drv_id = 4'd7;
            16'hfeff: drv_id = 4'd8; 16'hfdff: drv_id = 4'd9; 16'hfbff: drv_id = 4'd10;16'hf7ff: drv_id = 4'd11;
            16'hefff: drv_id = 4'd12;16'hdfff: drv_id = 4'd13;16'hbfff: drv_id = 4'd14;16'h7fff: drv_id = 4'd15;
            default: drv_id = 0;
        endcase
        tr.drv_id=drv_id;

        for(int i=0; i<4; i++)begin
            rcv_id[i] = drv_vif.ck_mon.din[drv_id];
            @(posedge drv_vif.clock);
        end
        tr.rcv_id = rcv_id;
    
        repeat(5)@(posedge drv_vif.clock);
        for(int i=0; i<8; i++)begin
            payload[i] = drv_vif.ck_mon.din[drv_id];
            @(posedge drv_vif.clock);
        end
        tr.payload = payload;

        `uvm_info(get_type_name(),$sformatf("drv_id is 'h%8x,rcv_id is 'h%8x, payload is 'h%8x", tr.drv_id, tr.rcv_id, tr.payload), UVM_LOW)
    endtask //
endclass //drv_monitor extends superClass

class drv_agent extends uvm_agent;
    drv_driver drv;
    drv_monitor mon;
    my_sequencer sqr;
    uvm_analysis_port #(my_trans) ap;
    
    `uvm_component_utils(drv_agent)

    function new(string name="drv_agent", uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = drv_driver::type_id::create("drv", this);
        mon = drv_monitor::type_id::create("mon",this);
        sqr = my_sequencer::type_id::create("sqr",this);
    endfunction
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
        ap = mon.ap;
    endfunction

endclass //my extends superClass


`endif