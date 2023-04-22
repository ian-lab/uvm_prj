package master_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    typedef enum { EAST, WEST, NORTH, SOUTH, LOCAL } port;
    class master_trans extends uvm_sequence_item;
        
        rand bit [7:0]  header;
        rand bit [15:0] payload[$];
        rand bit [3:0] x,y;
        rand port drv_port;   

        `uvm_object_utils_begin(master_trans)
            `uvm_field_int(header, UVM_ALL_ON)
            `uvm_field_queue_int(payload, UVM_ALL_ON)
            `uvm_field_int(x, UVM_ALL_ON)
            `uvm_field_int(y, UVM_ALL_ON)
            `uvm_field_enum(port, drv_port, UVM_ALL_ON)
        `uvm_object_utils_end      

        function new(string name="master_trans");
            super.new();
        endfunction 

        constraint ct{
            payload.size() inside {1,5};
            // header inside {valid_header(drv_port)};
            header==8'h11;
            x == header[7:4];
            y == header[3:0];
            solve drv_port before header;
            solve header before x;
            solve header before y;
        };
        
        typedef bit [7:0] headerlaoder[$]; 
        function  headerlaoder valid_header(port drv_port);
            bit [ 3:0] i,j;
            valid_header.delete();
            for(i=0; i<=2; i++)begin
                for(j=0; j<=2; j++)begin
                    if(drv_port == LOCAL)
                        if((i!=1) && (j!=1))
                            valid_header.push_back({i,j});
                    if(drv_port == WEST)
                        if(i>0)
                            valid_header.push_back({i,j});
                    if(drv_port == EAST)
                        if(i<2)
                            valid_header.push_back({i,j});
                    if(drv_port == NORTH)
                        if(j>0)
                            valid_header.push_back({i,j});
                    if(drv_port == SOUTH)
                        if(j<2)
                            valid_header.push_back({i,j});
                end
            end

        endfunction
    endclass 

    class master_sequencer extends uvm_sequencer #(master_trans);
        `uvm_component_utils(master_sequencer)
        function new(string name="master_sequencer", uvm_component parent);
            super.new(name, parent);
        endfunction 
    endclass 

    class master_driver extends uvm_driver #(master_trans);
        `uvm_component_utils(master_driver)

        virtual master_intf master_vif;
        int i; // packet cnt
        // master_trans master_tr;

        function new(string name="master_driver", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual master_intf)::get(this, "", "master_vif", master_vif))
                `uvm_fatal("set vif", "get master vif failed!!!")
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            while(master_vif.rst)begin
               
                master_vif.cb_drv.data <= 0;
                master_vif.cb_drv.rx <= 0;
                @(master_vif.cb_drv);
            end

            forever begin
                seq_item_port.get_next_item(req);
                // req.print();
                do_driver(req);
                seq_item_port.item_done();
            end
        endtask
        task do_driver(master_trans tr);
            master_vif.cb_drv.data <= {8'b0, tr.header};
            master_vif.cb_drv.rx <= 1;
            @(master_vif.cb_drv);
            wait(master_vif.cb_drv.credit == 1);

            master_vif.cb_drv.data <= tr.payload.size();
            master_vif.cb_drv.rx <= 1;
            @(master_vif.cb_drv);
            wait(master_vif.cb_drv.credit == 1);

            i=0;
            while( i < tr.payload.size())begin
                master_vif.cb_drv.data <= tr.payload[i];
                master_vif.cb_drv.rx <= 1;
                @(master_vif.cb_drv);
                wait(master_vif.cb_drv.credit == 1);
                i = i+1;
            end
            master_vif.cb_drv.data <= 0;
            master_vif.cb_drv.rx <= 0;
            @(master_vif.cb_drv);
        endtask

    endclass

    class master_monitor extends uvm_monitor;
        `uvm_component_utils(master_monitor)

        virtual master_intf master_vif;

        function new(string name="master_monitor", uvm_component parent);
            super.new(name, parent);
        endfunction 
    endclass

    class master_agent extends uvm_agent ;
        `uvm_component_utils(master_agent)

        master_sequencer master_sqr;
        master_driver master_drv;
        master_monitor master_mon;
        function new(string name="master_agent", uvm_component parent);
            super.new(name, parent);
        endfunction 

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            master_sqr = master_sequencer::type_id::create("master_sqr", this);
            master_drv = master_driver::type_id::create("master_drv", this);
            master_mon = master_monitor::type_id::create("master_mon", this);

        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            master_drv.seq_item_port.connect(master_sqr.seq_item_export);
        endfunction


    endclass
    
endpackage  