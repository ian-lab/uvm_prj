`ifndef MY_SCOREBOARD_SV
`define MY_SCOREBOARD_SV

class my_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(my_scoreboard)

    uvm_blocking_get_port #(my_trans) rf_mdl_port;
    uvm_blocking_get_port #(my_trans) rcv_mon_port;
    my_trans get_expect, get_actual;
    my_trans tmp_trans;
    my_trans expect_queue[$];
    bit result;
    bit [3:0] drv_id, rcv_id;
    bit [7:0] payload;

    covergroup router_cov;
        coverpoint drv_id;
        coverpoint rcv_id;
        coverpoint payload{bins paylaod[]={[0:255]};}
        cross drv_id, rcv_id;
        cross drv_id, payload;
        cross drv_id, rcv_id,payload;
    endgroup: router_cov

    function new(string name="my_scoreboard", uvm_component parent);
        super.new(name, parent);
        router_cov=new();
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rf_mdl_port = new("rf_mdl_port",this);
        rcv_mon_port = new("rcv_mon_port",this);
    endfunction

    task main_phase(uvm_phase phase);
        super.main_phase(phase);
        fork
            while(1)begin
                rf_mdl_port.get(get_expect);
                expect_queue.push_back(get_expect);
            end
            while(1)begin
                rcv_mon_port.get(get_actual);
                if(expect_queue.size() > 0)begin
                    tmp_trans = expect_queue.pop_front();
                    get_actual.drv_id = tmp_trans.drv_id;
                    result = get_actual.compare(tmp_trans);
                    if(result == 0)begin
                        `uvm_fatal(get_type_name(),$sformatf("compare failed, expected rcv_id is 'h%2x, actual rcv_id is 'h%2x,",tmp_trans.rcv_id, get_actual.rcv_id))
                    end
                    else begin
                        `uvm_info(get_type_name(), "compare successful", UVM_LOW)
                    end
                end
                else begin
                    `uvm_fatal(get_type_name(),$sformatf("recived from dut, but the expected que is empty"))
                end
                drv_id = tmp_trans.drv_id;
                rcv_id = tmp_trans.rcv_id;
                payload = tmp_trans.payload;
                router_cov.sample();
            end
        join

    endtask 

    function void report_phase(uvm_phase phase);
      string s;
      super.report_phase(phase);
      s = "\n---------------------------------------------------------------\n";
      s = {s, "COVERAGE SUMMARY \n"}; 
      s = {s, $sformatf("total coverage: %.1f \n", $get_coverage())}; 
      s = {s, $sformatf("  router coverage: %.1f \n", router_cov.get_coverage())}; 
      s = {s, "---------------------------------------------------------------\n"};
      `uvm_info(get_type_name(), s, UVM_LOW)
    endfunction

endclass //my_scoreboard extends uvm_scoreboard


`endif 