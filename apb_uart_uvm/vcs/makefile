all: cmp sim_all  

cmp:	
	vcs -full64 -sverilog -timescale=1ns/1ps -ntb_opts uvm-1.2 -top uart_tb -lca -f filelist.f -kdb -debug_all -LDFLAGS -Wl,--no-as-needed -cm line+cond+branch+fsm -fsdb

sim_all: sim_apb_uart_reg_test sim_apb_uart_baud_test sim_apb_uart_rx_tx_test sim_apb_uart_rx_tx_int_test sim_apb_uart_rx_error_test sim_apb_uart_modem_test

sim_apb_uart_reg_test:
	./simv -l sim_apb_uart_reg_test.log +UVM_TESTNAME=apb_uart_reg_test -cm line+cond+branch+fsm -cm_name sim_apb_uart_reg_test -cm_dir sim_apb_uart_reg_test.vdb
sim_apb_uart_baud_test:
	./simv -l sim_apb_uart_baud_test.log +UVM_TESTNAME=apb_uart_baud_test -cm line+cond+branch+fsm -cm_name sim_apb_uart_baud_test -cm_dir sim_apb_uart_baud_test.vdb
sim_apb_uart_rx_tx_test:
	./simv -l sim_apb_uart_rx_tx_test.log +UVM_TESTNAME=apb_uart_rx_tx_test -cm line+cond+branch+fsm -cm_name sim_apb_uart_rx_tx_test -cm_dir sim_apb_uart_rx_tx_test.vdb
sim_apb_uart_rx_tx_int_test:
	./simv -l sim_apb_uart_rx_tx_int_test.log +UVM_TESTNAME=apb_uart_rx_tx_int_test -cm line+cond+branch+fsm -cm_name sim_apb_uart_rx_tx_int_test -cm_dir sim_apb_uart_rx_tx_int_test.vdb
sim_apb_uart_rx_error_test:
	./simv -l sim_apb_uart_rx_error_test.log +UVM_TESTNAME=apb_uart_rx_error_test -cm line+cond+branch+fsm -cm_name sim_apb_uart_rx_error_test -cm_dir sim_apb_uart_rx_error_test.vdb
sim_apb_uart_modem_test:
	./simv -l sim_apb_uart_modem_test.log +UVM_TESTNAME=apb_uart_modem_test -cm line+cond+branch+fsm -cm_name apb_uart_modem_test -cm_dir apb_uart_modem_test.vdb
verdi:
	verdi -sv -f filelist.f
clean:
	rm -rf *.log *.vdb *simv* *.h *.key cg_report csrc vdCovLog


# all: work comp sim_all rpt_cg

# comp:
# 	vlog ../rtl/*.sv +cover=sbf
#     vlog -f filelist.f
#     vcs -full64 

# sim_all: sim_apb_uart_baud_test sim_apb_uart_rx_tx_test sim_apb_uart_rx_tx_int_test sim_apb_uart_rx_error_test sim_apb_uart_modem_test

# sim_apb_uart_reg_test:
#     vsim uart_tb +UVM_TESTNAME=apb_uart_reg_test -do "coverage save apb_uart_reg_test.ucdb -onexit;run -all" -c -l apb_uart_reg_test.log -coverage -voptargs=+acc
# sim_apb_uart_baud_test:
#     vsim uart_tb +UVM_TESTNAME=apb_uart_baud_test -do "coverage save apb_uart_baud_test.ucdb -onexit;run -all" -c -l apb_uart_baud_test.log -coverage -voptargs=+acc
# sim_apb_uart_rx_tx_test:
#     vsim uart_tb +UVM_TESTNAME=apb_uart_rx_tx_test -do "coverage save apb_uart_rx_tx_test.ucdb -onexit;run -all" -c -l apb_uart_rx_tx_test.log -coverage -voptargs=+acc
# sim_apb_uart_rx_tx_int_test:
#     vsim uart_tb +UVM_TESTNAME=apb_uart_rx_tx_int_test -do "coverage save apb_uart_rx_tx_int_test.ucdb -onexit;run -all" -l apb_uart_rx_tx_int_test.log -c -coverage
# sim_apb_uart_rx_error_test:
#     vsim uart_tb +UVM_TESTNAME=apb_uart_rx_error_test -do "coverage save apb_uart_rx_error_test.ucdb -onexit;run -all" -l apb_uart_rx_error_test.log -c -coverage
# sim_apb_uart_modem_test:
#     vsim uart_tb +UVM_TESTNAME=apb_uart_modem_test -do "coverage save apb_uart_modem_test.ucdb -onexit;run -all" -l apb_uart_modem_test.log -c -coverage

# rpt_cg:
#     vcover merge -out merge_coverage.ucdb apb_uart_reg_test.ucdb apb_uart_baud_test.ucdb apb_uart_rx_tx_test.ucdb apb_uart_rx_tx_int_test.ucdb apb_uart_rx_error_test.ucdb apb_uart_modem_test.ucdb
#     vcover report -details -html merge_coverage.ucdb
#     @echo "html has been created in ./sim/covhtmlreport"

# clean:
# 	rm -r work
# 	rm *.log transcript vsim.* *.ucdb
# 	rm -r covhtmlreport

