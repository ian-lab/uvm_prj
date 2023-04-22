import sys
import os
import re
run_time = sys.argv[1]
success = 0

for i in range(int(run_time)):
    log = str(i)+"_sim.log"
    cm = str(i)+"base_test"
    test_name = "base_test"
    cmp_cmd = ("vcs -full64 -kdb -debug_acc+all -debug_region+cell+encrypt -sverilog -ntb_opts uvm-1.2 +v2k\
              -timescale=1ns/1ps \
              -f filelist.f  -top tb \
              -LDFLAGS -Wl,--no-as-needed \
              -cm line+cond+branch+fsm")
    sim_cmd = (
        "./simv -l %s +UVM_TESTNAME=%s -cm line+cond+branch+fsm -cm_name %s -cm_dir %s.vdb" %(log, test_name, cm, cm)
    )
    os.system(cmp_cmd)
    os.system(sim_cmd)

for i in range(int(run_time)):
    log = str(i)+"_sim.log"
    log_file = open(log,"r")
    content = log_file.read()
    count = len(re.findall("successfull", content)) 
    if(count >= 1):
        success += 1 
if(success == int(run_time) ):
    print(" ***************************\n \
                     *\n \
                  *\n \
    *           *\n \
      *       *\n \
        *   *\n \
          *\n\
 ***************************")    
else:
    print(" *************************** \n \
        *       *               \n \
          *   *                 \n \
            *                   \n \
          *   *                 \n \
        *       *               \n \
***************************")             
print(" *******************************************************\n \
**\t total\t **\t succ\t **\t failed\t **\n \
**\t %d\t **\t %d\t **\t %d\t **\n \
*******************************************************\n \
      " %(int(run_time), success, int(run_time) - success))