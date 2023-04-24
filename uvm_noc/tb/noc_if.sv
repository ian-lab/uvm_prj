
/*
Each of the five interfaces has the following ports:
--                             PORT
--                         _____________
--                   RX ->|             |-> TX
--              DATA_IN ->|             |-> DATA_OUT
--             CLOCK_RX ->|             |-> CLOCK_TX
--             CREDIT_O <-|             |<- CREDIT_I
                           _____________
*/
interface master_intf(
    input clk,
    input rst
);
    logic  rx, credit;
    logic [15:0] data;

    clocking cb_drv @(posedge clk) ;
        default input #1 output #1;
        output  rx, data;
        input   credit;
    endclocking
    clocking cb_mon @(posedge clk) ;
        default input #1 output #1;
        input   rx, credit, data;
    endclocking
endinterface 

interface slave_intf(
    input clk,
    input rst
);
    logic  tx, credit, tx_clk;
    logic [15:0] data;

    clocking cb_drv @(posedge clk) ;
        default input #1 output #1;
        input   tx, data, tx_clk;
        output  credit;
    endclocking
    clocking cb_mon @(posedge clk) ;
        default input #1 output #1;
        input   tx,tx_clk, credit, data;
    endclocking

endinterface 