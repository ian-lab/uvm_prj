package apb_uart_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_pkg::*;
    import apb_pkg::*;
    import modem_pkg::*;
    import apb_uart_rgm_pkg::*;

    //==================================
    // reg scoreboard
    //==================================
    class reg_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(reg_scoreboard)
        uvm_tlm_analysis_fifo #(apb_trans) apb_fifo;
        apb_trans tr;
        bit write;
        bit [7:0] addr;
        bit [7:0] reg_data;
        bit [7:0] IER;
        bit [7:0] IIR;
        bit [7:0] FCR;
        bit [7:0] LCR;
        bit [7:0] MCR;
        bit [7:0] LSR;
        bit [7:0] MSR;
        bit Loopback;
 
        covergroup reg_cov();
            RW : coverpoint write{
                bins read = {0};
                bins write = {1};
            }
            ADDR : coverpoint addr{
                bins data = {8'h00};
                bins IER  = {8'h04};
                bins IIR_FCR = {8'h08};
                bins LCR = {8'h0c};
                bins MCR = {8'h10};
                bins LSR = {8'h14};
                bins MSR = {8'h18};
                bins DIV1 = {8'h1c};
                bins DIV2 = {8'h20};
            }
            REG_ACCESS: cross RW, ADDR {
                ignore_bins read_only = binsof(ADDR) intersect {8'h14, 8'h18} && binsof(RW) intersect {1};
            }
        endgroup

        covergroup IER_cov;
            IRQ_EN : coverpoint IER[3:0]{
                wildcard bins rx_irq    = {4'b???1};
                wildcard bins tx_irq    = {4'b??1?};
                wildcard bins rls_irq   = {4'b?1??};
                wildcard bins modem_irq = {4'b1???};
            }
        endgroup

        covergroup IIR_cov;
            IIR : coverpoint IIR[3:0]{
                bins no_irq           = {4'h1};
                bins rx_status_irq    = {4'h6};
                bins rx_data_irq      = {4'h4};
                // bins rx_time_out_irq  = {4'hc};
                bins tx_empty_irq     = {4'h2};
                bins modem_irq        = {4'h0};
            }
        endgroup

        covergroup FCR_cov;
            RX_FIFO_TH : coverpoint FCR[7:6]{
                bins threshold_1   = {4'h0};
                bins threshold_4   = {4'h1};
                bins threshold_8   = {4'h2};
                bins threshold_14  = {4'h3};
            }
        endgroup

        covergroup LCR_cov;
            WORD_LENGTH: coverpoint LCR[1:0]{
                bins bits_5 = {0};
                bins bits_6 = {1};
                bins bits_7 = {2};
                bins bits_8 = {3};
            }
            STOP_BITS: coverpoint LCR[2]{
                bins stop_1 = {0};
                bins stop_2 = {1};
            }
            PARITY: coverpoint LCR[5:3]{
                bins no_parity      = {3'b000, 3'b010, 3'b100, 3'b110};
                bins odd_parity     = {3'b001};
                bins even_parity    = {3'b011};
                bins stick_1_parity = {3'b101};
                bins stick_0_parity = {3'b111};
            }
            WORD_FORMAT: cross WORD_LENGTH, STOP_BITS, PARITY;
        endgroup

        covergroup MCR_cov;
            DTR : coverpoint MCR[0];
            RTS : coverpoint MCR[1];
            OUT1 : coverpoint MCR[2];
            OUT2 : coverpoint MCR[3];
            LOOPBACK : coverpoint MCR[4]{
                bins normal = {0};
                bins loopback = {1};
            }
            MCR_SET: cross DTR, RTS, OUT1, OUT2, LOOPBACK;
        endgroup

        covergroup LSR_cov;
            DR: coverpoint LSR[0];
            OE: coverpoint LSR[1];
            PE: coverpoint LSR[2];
            FE: coverpoint LSR[3];
            BI: coverpoint LSR[4];
            TX_FIFO_EMPTY: coverpoint LSR[5];
            TX_EMPTY: coverpoint LSR[6];
            // FIFO_ERROR: coverpoint LSR[7];
        endgroup

        covergroup MSR_cov;
            DCTS : coverpoint MSR[0];
            RTS  : coverpoint MSR[1];
            TERI : coverpoint MSR[2];
            DDCD : coverpoint MSR[3];
            MSR4 : coverpoint MSR[4];
            MSR5 : coverpoint MSR[5];
            MSR6 : coverpoint MSR[6];
            MSR7 : coverpoint MSR[7];
            LOOPBACK : coverpoint MCR[4]{
                bins normal = {0};
                bins loopback = {1};
            }
            MSR_GET: cross DCTS, RTS, TERI, DDCD, MSR4, MSR5, MSR6, MSR7, LOOPBACK;
        endgroup
        
        function new(string name="reg_scoreboard", uvm_component parent);
            super.new(name,parent);
            reg_cov = new();
            IER_cov = new();
            IIR_cov = new();
            FCR_cov = new();
            LCR_cov = new();
            MCR_cov = new();
            LSR_cov = new();
            MSR_cov = new();
        endfunction 
        
        function void build_phase(uvm_phase phase);
            apb_fifo=new("apb_fifo",this);
        endfunction

        task run_phase(uvm_phase phase);
            forever begin
                apb_fifo.get(tr);
                write = (tr.trans_kind == WRITE);
                addr = tr.addr;
                reg_cov.sample();     
                // IER 
                if(addr == 8'h04)begin
                    IER = tr.data[3:0];
                    IER_cov.sample();
                end
                // IIR
                if(addr == 8'h08 && tr.trans_kind == READ)begin
                    IIR = tr.data;
                    IIR_cov.sample();
                end
                // FCR
                if(addr == 8'h08 && tr.trans_kind == WRITE)begin
                    FCR = tr.data;
                    FCR_cov.sample();
                end
                // LCR
                if(addr == 8'h0c)begin
                    LCR = tr.data;
                    LCR_cov.sample();
                end
                // MCR
                if(addr == 8'h10)begin
                    MCR = tr.data[4:0];
                    MCR_cov.sample();
                end
                // LSR
                if(addr == 8'h14 && tr.trans_kind == READ)begin
                    LSR = tr.data;
                    LSR_cov.sample();
                end
                // MSR
                if(addr == 8'h18 && tr.trans_kind == READ)begin
                    MSR = tr.data;
                    MSR_cov.sample();
                end
            end
        endtask
    endclass 

    //==================================
    // baud_scoreboard
    //==================================
    class baud_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(baud_scoreboard)
        uvm_tlm_analysis_fifo #(apb_trans) apb_fifo;
        virtual irq_intf irq_vif;

        apb_trans  apb_actual;
        int        clk_count;
        bit [15:0] div;
        bit        new_div;

        covergroup baud_div_cov;
            coverpoint div{
            bins baud_div[] = { 16'h0001, 16'h0002, 16'h0004, 16'h0008,
                                16'h0010, 16'h0020, 16'h0040, 16'h0080,
                                16'h0100, 16'h0200, 16'h0400, 16'h0800,
                                16'h1000, 16'h2000, 16'h4000, 16'h8000,
                                16'hfffe, 16'hfffd, 16'hfffb, 16'hfff7,
                                16'hffef, 16'hffdf, 16'hffbf, 16'hff7f,
                                16'hfeff, 16'hfdff, 16'hfbff, 16'hf7ff,
                                16'hefff, 16'hdfff, 16'hbfff, 16'h7fff,
                                16'h00ff, 16'hff00, 16'hffff};
            }
        endgroup

        function new(string name="baud_scoreboard", uvm_component parent);
            super.new(name, parent);
            baud_div_cov = new();
        endfunction 

        function void build_phase(uvm_phase phase);
            if(!uvm_config_db#(virtual irq_intf)::get(this, "","irq_vif",irq_vif))   
                 `uvm_fatal("get vif","get vif failed")
            apb_fifo=new("apb_fifo",this);
        endfunction

        task run_phase(uvm_phase phase);
            fork
                monitor_apb;
                monitor_clk;
            join
        endtask 
        task monitor_apb;
            forever begin
                apb_fifo.get(apb_actual);
                new_div = 0;
                if((apb_actual.addr==16'h1c) && (apb_actual.trans_kind==WRITE))begin
                    div[7:0] = apb_actual.data;
                    new_div = 0;
                end
                else if((apb_actual.addr==16'h20) && (apb_actual.trans_kind==WRITE))begin
                    div[15:8] = apb_actual.data;
                    new_div = 1;
                end

                if(new_div)begin
                    @(posedge irq_vif.baud_out)
                        clk_count = 0;
                    @(posedge irq_vif.baud_out)
                    if(clk_count == div)
                        `uvm_info("scoreboard",$sformatf("div is %4h, detect successful", div),UVM_LOW)
                    else
                        `uvm_fatal("scoreboard",$sformatf("detect failed, actual clk_count is %x, expected div is %x ", clk_count,div))
                    new_div = 0;
                    baud_div_cov.sample();
                end
                
            end
        endtask
        task monitor_clk;
            forever begin
                @(posedge irq_vif.clk)
                    clk_count++;
            end
        endtask
    endclass

    //==================================
    // rx_scoreboard
    //==================================
    class rx_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(rx_scoreboard)
        uvm_tlm_analysis_fifo #(apb_trans) apb_fifo;
        uvm_tlm_analysis_fifo #(uart_trans) uart_rx_fifo;
        uvm_status_e status;
        apb_uart_rgm rgm;

        apb_trans  apb_actual;
        uart_trans uart_expected;
        bit [10:0]  data_q[$];
        bit [10:0]  expected_data;
        bit [10:0]  tmp_data;
        bit [7:0]   LCR;
        bit         frame_err;
        bit         parity_err;
        bit         rx_break;
        covergroup rx_cov;
            WORD_LENGTH: coverpoint LCR[1:0]{
                bins bits_5 = {0};
                bins bits_6 = {1};
                bins bits_7 = {2};
                bins bits_8 = {3};
            }
            STOP_BITS: coverpoint LCR[2]{
                bins stop_1 = {0};
                bins stop_2 = {1};
            }
            PARITY: coverpoint LCR[5:3]{
                bins no_parity      = {3'b000, 3'b010, 3'b100, 3'b110};
                bins odd_parity     = {3'b001};
                bins even_parity    = {3'b011};
                bins stick_1_parity = {3'b101};
                bins stick_0_parity = {3'b111};
            }
            WORD_FORMAT: cross WORD_LENGTH, STOP_BITS, PARITY;
        endgroup

        function new(string name="rx_scoreboard", uvm_component parent);
            super.new(name, parent);
            rx_cov = new();
        endfunction 

        function void build_phase(uvm_phase phase);
            apb_fifo = new("apb_fifo",this);
            uart_rx_fifo = new("uart_rx_fifo",this);
        endfunction

        task run_phase(uvm_phase phase);
            fork
                monitor_apb;
                monitor_uart;
            join
        endtask 

        task monitor_apb;
            forever begin
                apb_fifo.get(apb_actual);
                if(apb_actual.addr==0 && apb_actual.trans_kind==READ)begin
                    if(data_q.size() > 0)begin
                        tmp_data = data_q.pop_front();
                        frame_err = tmp_data[9];
                        parity_err = tmp_data[8];
                        rx_break = tmp_data[10];
                        if (tmp_data[7:0] == apb_actual.data)
                            `uvm_info("scoreboard",$sformatf("rx data compare successful, expected rx data is 'h%2x, actual rx data is 'h%2x",tmp_data[7:0], apb_actual.data),UVM_LOW)
                        else
                            `uvm_error("scoreboard",$sformatf("rx data compare failed, expected rx data is 'h%2x, actual rx data is 'h%2x",tmp_data[7:0], apb_actual.data))
                    end
                    else begin
                        `uvm_fatal("scoreboard","rx seque is empty")
                    end
                    rx_cov.sample();
                end
                else if(apb_actual.addr==8'h14 && apb_actual.trans_kind==READ)begin                  
                    if(apb_actual.data[2] != parity_err)
                        `uvm_error("scoreboard",$sformatf("parity error detect failed, expected is 'h%x, actual is 'h%1x", parity_err, apb_actual.data[2]))
                    if(apb_actual.data[3] != frame_err)
                        `uvm_error("scoreboard", $sformatf("frame error detect failed, expected is 'h%x, actual is 'h%1x",frame_err, apb_actual.data[3]))
                    if(apb_actual.data[4] != rx_break)
                        `uvm_error("scoreboard", $sformatf("rx break detect failed, expected is 'h%x, actual is 'h%1x",rx_break, apb_actual.data[4]))    
                end
            end
        endtask
        task monitor_uart;
            forever begin
                uart_rx_fifo.get(uart_expected);
                expected_data={uart_expected.rx_break, uart_expected.frame_err, uart_expected.parity_err, uart_expected.data};
                data_q.push_back(expected_data);
                LCR = uart_expected.LCR;
            end
        endtask 
    endclass 

    //==================================
    // tx_scoreboard
    //==================================
    class tx_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(tx_scoreboard)
        uvm_tlm_analysis_fifo #(apb_trans) apb_fifo;
        uvm_tlm_analysis_fifo #(uart_trans) uart_tx_fifo;
        
        apb_trans  apb_expected;
        uart_trans uart_actual;
        bit [7:0]  data_q[$];
        bit [7:0]  tmp_data; 
        bit [7:0]  LCR;
        covergroup tx_cov;
            WORD_LENGTH: coverpoint LCR[1:0]{
                bins bits_5 = {0};
                bins bits_6 = {1};
                bins bits_7 = {2};
                bins bits_8 = {3};
            }
            STOP_BITS: coverpoint LCR[2]{
                bins stop_1 = {0};
                bins stop_2 = {1};
            }
            PARITY: coverpoint LCR[5:3]{
                bins no_parity      = {3'b000, 3'b010, 3'b100, 3'b110};
                bins odd_parity     = {3'b001};
                bins even_parity    = {3'b011};
                bins stick_1_parity = {3'b101};
                bins stick_0_parity = {3'b111};
            }
            WORD_FORMAT: cross WORD_LENGTH, STOP_BITS, PARITY;
        endgroup

        function new(string name="tx_scoreboard", uvm_component parent);
            super.new(name, parent);
            tx_cov = new();
        endfunction

        function void build_phase(uvm_phase phase);
            apb_fifo = new("apb_fifo",this);
            uart_tx_fifo = new("uart_tx_fifo",this);
        endfunction

        task run_phase(uvm_phase phase);
            fork
                monitor_apb;
                monitor_uart;
            join
        endtask 

        task monitor_apb;
            forever begin
                apb_fifo.get(apb_expected);
                if((apb_expected.addr==0) && (apb_expected.trans_kind==WRITE))begin
                    data_q.push_back(apb_expected.data);
                end
            end
        endtask

        task monitor_uart;
            forever begin
                uart_tx_fifo.get(uart_actual);
                if(data_q.size() > 0)begin
                    tmp_data = data_q.pop_front();
                    LCR = uart_actual.LCR;
                    if(uart_actual.parity_err) begin
                        `uvm_error("scoreboard",$sformatf("tx data parity error"))
                    end
                    if (tmp_data == uart_actual.data)
                        `uvm_info("scoreboard",$sformatf("tx data compare successful, expected tx data is 'h%2x, actual tx data is 'h%2x",tmp_data, uart_actual.data), UVM_LOW)
                    else
                        `uvm_error("scoreboard",$sformatf("tx data compare failed, expected tx data is 'h%2x, actual tx data is 'h%2x",tmp_data, uart_actual.data))
                    end
                else begin
                     `uvm_fatal("scoreboard", "tx seque is empty")
                end
                tx_cov.sample();
            end
        endtask 
    endclass 

    //==================================
    // modem scoreboard
    //==================================
    class modem_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(modem_scoreboard)
        uvm_tlm_analysis_fifo #(apb_trans) apb_fifo;
        uvm_tlm_analysis_fifo #(modem_trans) modem_fifo;
        apb_trans apb_tr;
        modem_trans modem_tr;
        bit DTR;
        bit RTS;
        bit OUT1;
        bit OUT2;
        bit Loopback;
        // detect the change of modem input signal
        bit last_CTS;
        bit last_DSR;
        bit last_RI;
        bit last_DCD;
        bit delta_CTS;
        bit delta_DSR;
        bit trailling_RI;
        bit delta_DCD;

        function new(string name="modem_scoreboard", uvm_component parent);
            super.new(name, parent);
        endfunction 

        function void build_phase(uvm_phase phase);
            apb_fifo = new("apb_fifo",this);
            modem_fifo = new("modem_fifo",this);
        endfunction

        task run_phase(uvm_phase phase);
            fork
                monitor_apb;
                monitor_modem;
            join
        endtask

        task monitor_apb;
        forever begin
            apb_fifo.get(apb_tr);
            if((apb_tr.addr == 8'h10) && (apb_tr.trans_kind == WRITE))begin
                DTR = apb_tr.data[0];
                RTS = apb_tr.data[1];
                OUT1 = apb_tr.data[2];
                OUT2 = apb_tr.data[3];   
                Loopback = apb_tr.data[4];  
            end
            if((apb_tr.addr == 8'h18) && (apb_tr.trans_kind == READ))begin
                if(apb_tr.data[0] != delta_CTS)
                    `uvm_error("scoreboard", $sformatf("DCTS read from MSR error, MSR is %1b, actual is %1b", apb_tr.data[0], delta_CTS))
                else
                    `uvm_info("scoreboard", $sformatf("delta_CTS compare successful"), UVM_LOW)
                if(apb_tr.data[1] != delta_DSR)
                    `uvm_error("scoreboard", $sformatf("DDSR read from MSR error, MSR is %1b, actual is %1b", apb_tr.data[1], delta_DSR))
                else
                    `uvm_info("scoreboard", $sformatf("delta_DSR compare successful"), UVM_LOW)
                if(apb_tr.data[2] != trailling_RI)
                    `uvm_error("scoreboard", $sformatf("TERI read from MSR error, MSR is %1b, actual is %1b", apb_tr.data[2], trailling_RI))
                else
                    `uvm_info("scoreboard", $sformatf("trailling_RI compare successful"), UVM_LOW)
                if(apb_tr.data[3] != delta_DCD)
                    `uvm_error("scoreboard", $sformatf("DDCD read from MSR error, MSR is %1b, actual is %1b", apb_tr.data[3], delta_DCD))
                else
                    `uvm_info("scoreboard", $sformatf("delta_DCD compare successful"), UVM_LOW)
                if(Loopback == 0)begin
                    if(apb_tr.data[4] != ~last_CTS)
                        `uvm_error("scoreboard", $sformatf("CTS read from MSR error, MSR is %1b, actual is %1b", apb_tr.data[4], last_CTS))
                    else
                        `uvm_info("scoreboard", $sformatf("last_CTS compare successful"), UVM_LOW)
                    if(apb_tr.data[5] != ~last_DSR)
                        `uvm_error("scoreboard", $sformatf("DSR read from MSR error, MSR is %1b, actual is %1b", apb_tr.data[5], last_DSR))
                    else
                        `uvm_info("scoreboard", $sformatf("last_DSR compare successful"), UVM_LOW)
                    if(apb_tr.data[6] != ~last_RI)
                        `uvm_error("scoreboard", $sformatf("RI read from MSR error, MSR is %1b, actual is %1b", apb_tr.data[6], last_RI))
                    else
                        `uvm_info("scoreboard", $sformatf("last_RI compare successful"), UVM_LOW)
                    if(apb_tr.data[7] != ~last_DCD)
                        `uvm_error("scoreboard", $sformatf("DCD read from MSR error, MSR is %1b, actual is %1b", apb_tr.data[7], last_DCD))
                    else
                        `uvm_info("scoreboard", $sformatf("last_DCD compare successful"), UVM_LOW)
                end
                else begin
                    if(apb_tr.data[4] != RTS)
                        `uvm_error("scoreboard", $sformatf("RTS read from MSR error, MSR is %1b, actual is %1b", apb_tr.data[4], RTS))
                    else
                        `uvm_info("scoreboard", $sformatf("RTS compare successful"), UVM_LOW)
                    if(apb_tr.data[5] != DTR)
                        `uvm_error("scoreboard", $sformatf("DTR read from MSR error, MSR is %1b, actual is %1b", apb_tr.data[5], DTR))
                    else
                        `uvm_info("scoreboard", $sformatf("DTR compare successful"), UVM_LOW)
                    if(apb_tr.data[6] != OUT1)
                        `uvm_error("scoreboard", $sformatf("OUT1 read from MSR error, MSR is %1b, actual is %1b", apb_tr.data[6], OUT1))
                    else
                        `uvm_info("scoreboard", $sformatf("OUT1 compare successful"), UVM_LOW)
                    if(apb_tr.data[7] != OUT2)
                        `uvm_error("scoreboard", $sformatf("OUT2 read from MSR error, MSR is %1b, actual is %1b", apb_tr.data[7], OUT2))
                    else
                        `uvm_info("scoreboard", $sformatf("OUT2 compare successful"), UVM_LOW)
                end
                delta_CTS = 0;
                delta_DSR = 0;
                trailling_RI = 0;
                delta_DCD = 0;
            end
        end
        endtask

        task monitor_modem;
        forever begin
            modem_fifo.get(modem_tr);
            // input
            if(modem_tr.modem_bits[0] != last_CTS)
                delta_CTS = 1;
            if(modem_tr.modem_bits[1] != last_DSR)
                delta_DSR = 1;
            if(modem_tr.modem_bits[2] != last_DCD)
                delta_DCD = 1;
            if((modem_tr.modem_bits[3] == 0) && (last_RI == 1))
                trailling_RI = 1;
            // output
            if(modem_tr.kind == 1) begin
                if(modem_tr.modem_bits[4] != ~RTS)
                    `uvm_error("scoreboard",$sformatf("RTS output don't match to MCR, MCR is %1b, output is %1b", RTS, modem_tr.modem_bits[4]))
                else
                    `uvm_info("scoreboard", $sformatf("RTS compare successful"), UVM_LOW)
                if(modem_tr.modem_bits[5] != ~DTR)
                    `uvm_error("scoreboard",$sformatf("DTR output don't match to MCR, MCR is %1b, output is %1b", DTR, modem_tr.modem_bits[5]))
                else
                    `uvm_info("scoreboard", $sformatf("DTR compare successful"), UVM_LOW)
                if(modem_tr.modem_bits[6] != OUT1)
                    `uvm_error("scoreboard",$sformatf("OUT1 output don't match to MCR, MCR is %1b, output is %1b", OUT1, modem_tr.modem_bits[6]))
                else
                    `uvm_info("scoreboard", $sformatf("OUT1 compare successful"), UVM_LOW)
                if(modem_tr.modem_bits[7] != OUT2)
                    `uvm_error("scoreboard",$sformatf("OUT2 output don't match to MCR, MCR is %1b, output is %1b", OUT2, modem_tr.modem_bits[7]))
                else
                    `uvm_info("scoreboard", $sformatf("OUT2 compare successful"), UVM_LOW)
            end
            last_CTS = modem_tr.modem_bits[0];
            last_DSR = modem_tr.modem_bits[1];
            last_DCD = modem_tr.modem_bits[2];
            last_RI  = modem_tr.modem_bits[3];
        end
        endtask
    endclass 

    //==================================
    // adapter
    //==================================
    class reg2apb_adapter extends uvm_reg_adapter;
        `uvm_object_utils(reg2apb_adapter)
        function new(string name="reg2apb_adapter");
            super.new(name);
        endfunction 

        function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
            apb_trans tr=apb_trans::type_id::create("t");
            tr.trans_kind = (rw.kind == UVM_WRITE) ? WRITE : READ;
            tr.addr = rw.addr;
            tr.data = rw.data;
            // tr.idle_cycles = 1;
            return tr;
        endfunction

        function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
            apb_trans tr;
            if(!$cast(tr, bus_item))begin
                `uvm_fatal("cast", "Provided bus_item is not of the correct type")
                return;
            end
            rw.kind = (tr.trans_kind == WRITE) ? UVM_WRITE : UVM_READ;
            rw.addr = tr.addr;
            rw.data = tr.data;
            // rw.status = t.trans_status == OK ? UVM_IS_OK : UVM_NOT_OK;
        endfunction
    endclass 

    //==================================
    // virtual sequencer
    //==================================
    class apb_uart_virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);
        `uvm_component_utils(apb_uart_virtual_sequencer)
        apb_sequencer apb_sqr;
        uart_sequencer uart_rx_sqr;
        modem_sequencer modem_sqr;
        apb_uart_rgm rgm;
        virtual apb_intf apb_vif;
        virtual irq_intf irq_vif;
        virtual modem_intf modem_vif;
        uart_cfg uart_rx_cfg;
        uart_cfg uart_tx_cfg;

        function new(string name="apb_uart_virtual_sequencer", uvm_component parent);
            super.new(name, parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
            if(!uvm_config_db#(apb_uart_rgm)::get(this, "", "rgm", rgm))
                `uvm_fatal("get rgm","get rgm failed")  
            if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_vif",apb_vif))   
                 `uvm_fatal("get vif","get vif failed")
            if(!uvm_config_db#(virtual irq_intf)::get(this, "", "irq_vif", irq_vif))   
                 `uvm_fatal("get vif","get vif failed")
            if(!uvm_config_db#(virtual modem_intf)::get(this, "", "modem_vif", modem_vif))   
                 `uvm_fatal("get vif","get vif failed")
            if(!uvm_config_db #(uart_cfg)::get(this, "", "uart_rx_cfg", uart_rx_cfg))
                `uvm_fatal("get cfg","get config failed")    
            if(!uvm_config_db #(uart_cfg)::get(this, "", "uart_tx_cfg", uart_tx_cfg))
                `uvm_fatal("get cfg","get config failed")  
        endfunction
    endclass 

    class apb_uart_env extends uvm_component;
        `uvm_component_utils(apb_uart_env)

        apb_agent apb_agt;
        apb_config apb_cfg;
        uart_agent uart_rx_agt;
        uart_cfg uart_rx_cfg;
        uart_agent uart_tx_agt;
        uart_cfg uart_tx_cfg;
        modem_agent modem_agt;
        
        apb_uart_virtual_sequencer vir_sqr;

        baud_scoreboard baud_scb;
        rx_scoreboard rx_scb;
        tx_scoreboard tx_scb;
        modem_scoreboard modem_scb;
        reg_scoreboard reg_scb;
        
        reg2apb_adapter reg_adapter;
        uvm_reg_predictor #(apb_trans) reg_predictor;
        apb_uart_rgm rgm;

        function new(string name="apb_uart_env", uvm_component parent);
            super.new(name,parent);
        endfunction 

        function void build_phase(uvm_phase phase);
            apb_cfg = apb_config::type_id::create("apb_cfg");
            uart_rx_cfg = uart_cfg::type_id::create("uart_rx_cfg");
            uart_tx_cfg = uart_cfg::type_id::create("uart_tx_cfg");
            uart_tx_cfg.is_active=UVM_PASSIVE;

            apb_agt=apb_agent::type_id::create("apb_agt",this);
            uvm_config_db#(apb_config)::set(this,"apb_agt*","apb_cfg",apb_cfg);
            uart_rx_agt = uart_agent::type_id::create("uart_rx_agt",this);
            uvm_config_db #(uart_cfg)::set(this,"uart_rx_agt*","uart_cfg",uart_rx_cfg);
            uvm_config_db #(uart_cfg)::set(this,"vir_sqr","uart_rx_cfg",uart_rx_cfg);
            uart_tx_agt = uart_agent::type_id::create("uart_tx_agt", this);
            uvm_config_db #(uart_cfg)::set(this, "uart_tx_agt*", "uart_cfg", uart_tx_cfg);
            uvm_config_db #(uart_cfg)::set(this,"vir_sqr","uart_tx_cfg",uart_tx_cfg);
            modem_agt = modem_agent::type_id::create("modem_agt", this);

            vir_sqr = apb_uart_virtual_sequencer::type_id::create("vir_sqr", this);

            baud_scb = baud_scoreboard::type_id::create("baud_scb", this);
            rx_scb = rx_scoreboard::type_id::create("rx_scb",this);
            tx_scb = tx_scoreboard::type_id::create("tx_scb",this);
            modem_scb = modem_scoreboard::type_id::create("modem_scb",this);
            reg_scb = reg_scoreboard::type_id::create("reg_scb",this);

            rgm = apb_uart_rgm::type_id::create("rgm", this);
            rgm.build();
            uvm_config_db#(apb_uart_rgm)::set(this,"*","rgm",rgm);
            reg_predictor = uvm_reg_predictor#(apb_trans)::type_id::create("reg_predictor",this);
            reg_adapter = reg2apb_adapter::type_id::create("reg_adapter", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            uart_rx_agt.ap.connect(rx_scb.uart_rx_fifo.analysis_export);
            uart_tx_agt.ap.connect(tx_scb.uart_tx_fifo.analysis_export);
            modem_agt.ap.connect(modem_scb.modem_fifo.analysis_export);
            apb_agt.ap.connect(baud_scb.apb_fifo.analysis_export);
            apb_agt.ap.connect(rx_scb.apb_fifo.analysis_export);
            apb_agt.ap.connect(tx_scb.apb_fifo.analysis_export);
            apb_agt.ap.connect(modem_scb.apb_fifo.analysis_export);
            apb_agt.ap.connect(reg_scb.apb_fifo.analysis_export);
            
            vir_sqr.apb_sqr = apb_agt.sqr;
            vir_sqr.uart_rx_sqr = uart_rx_agt.sqr;
            vir_sqr.modem_sqr = modem_agt.sqr;
            
            rgm.map.set_sequencer(apb_agt.sqr, reg_adapter);
            apb_agt.ap.connect(reg_predictor.bus_in);
            reg_predictor.map = rgm.map;
            reg_predictor.adapter = reg_adapter;

            rx_scb.rgm = rgm;

        endfunction
    endclass 

endpackage