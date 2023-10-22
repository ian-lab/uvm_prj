all: cmp sim_all  

cmp:	
	vcs -full64 -sverilog -timescale=1ns/1ps -ntb_opts uvm-1.2 -top tb_sha_1 -lca -f filelist.f -kdb -fsdb -debug_all -LDFLAGS -Wl,--no-as-needed -cm line+branch+fsm

sim_all: sim_base_test

sim_base_test:
	./simv -l base_test.log +UVM_TESTNAME=base_test -cm line+branch+fsm -cm_name base_test -cm_dir base_test.vdb

verdi:
	verdi -sv -f filelist.f

clean:
	rm -rf *.log *.vdb *simv* *.h *.key cg_report csrc vdCovLog
