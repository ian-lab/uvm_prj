all: cmp sim_all  

cmp:	
	vcs -full64 -sverilog -timescale=1ns/1ps -ntb_opts uvm-1.2 -top tb_router -lca -f filelist.f -kdb -debug_all -LDFLAGS -Wl,--no-as-needed -cm line+cond+branch+fsm

sim_all: sim_base_test

sim_base_test:
	./simv -l base_test.log +UVM_TESTNAME=base_test -cm line+cond+branch+fsm -cm_name base_test -cm_dir base_test.vdb

clean:
	rm -rf *.log *.vdb *simv* *.h *.key cg_report csrc vdCovLog novas.* verdiLog
