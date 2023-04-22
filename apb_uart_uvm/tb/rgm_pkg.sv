package apb_uart_rgm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class txd_reg extends uvm_reg;
    `uvm_object_utils(txd_reg)
    rand uvm_reg_field data;

    function new(string name = "txd_reg");
      super.new(name, 8, UVM_CVR_ALL);
    endfunction
    virtual function void build();
      data = uvm_reg_field::type_id::create("data");
      data.configure(this, 8, 0, "WO", 0, 'h0, 1, 0, 0);
    endfunction

  endclass

  class rxd_reg extends uvm_reg;
    `uvm_object_utils(rxd_reg)
    rand uvm_reg_field data;

    function new(string name = "rxd_reg");
      super.new(name, 8, UVM_CVR_ALL);
    endfunction
    virtual function void build();
      data = uvm_reg_field::type_id::create("data");
      data.configure(this, 8, 0, "RO", 0, 'h0, 1, 0, 0);
    endfunction
  endclass

  class IER_reg extends uvm_reg;
    `uvm_object_utils(IER_reg)
    rand uvm_reg_field RDI;
    rand uvm_reg_field TXE;
    rand uvm_reg_field RXS;
    rand uvm_reg_field MSI;
    rand uvm_reg_field unused;

    function new(string name = "IER_reg");
      super.new(name, 8, UVM_CVR_ALL);
    endfunction
    virtual function void build();
      RDI = uvm_reg_field::type_id::create("RDI");
      TXE = uvm_reg_field::type_id::create("TXE");
      RXS = uvm_reg_field::type_id::create("RXS");
      MSI = uvm_reg_field::type_id::create("MSI");
      unused = uvm_reg_field::type_id::create("unused");
      RDI.configure(this, 1, 0, "RW", 0, 'h0, 1, 0, 0);
      TXE.configure(this, 1, 1, "RW", 0, 'h0, 1, 0, 0);
      RXS.configure(this, 1, 2, "RW", 0, 'h0, 1, 0, 0);
      MSI.configure(this, 1, 3, "RW", 0, 'h0, 1, 0, 0);
      unused.configure(this, 4, 4, "RW", 0, 'h0, 1, 0, 0);
    endfunction
  endclass

  class IIR_reg extends uvm_reg;
    `uvm_object_utils(IIR_reg)
    rand uvm_reg_field ID;
    rand uvm_reg_field unused;
    function new(string name = "IIR_reg");
      super.new(name, 8, UVM_CVR_ALL);
    endfunction
    virtual function void build();
      ID = uvm_reg_field::type_id::create("ID");
      unused = uvm_reg_field::type_id::create("unused");
      ID.configure(this, 4, 0, "RO", 0, 'h1, 1, 0, 0);
      unused.configure(this, 4, 4, "RO", 0, 'hc, 1, 0, 0);
    endfunction
  endclass

  class FCR_reg extends uvm_reg;
    `uvm_object_utils(FCR_reg)
    rand uvm_reg_field unused;
    rand uvm_reg_field RFITL;
    function new(string name = "FCR_reg");
      super.new(name, 8, UVM_CVR_ALL);
    endfunction
    virtual function void build();
      unused = uvm_reg_field::type_id::create("unused");
      RFITL = uvm_reg_field::type_id::create("RFITL");
      unused.configure(this, 6, 0, "WO", 0, 'h0, 1, 0, 0);
      RFITL.configure(this, 2, 6, "WO", 0, 'h3, 1, 0, 0);
    endfunction
  endclass

  class LCR_reg extends uvm_reg;
    `uvm_object_utils(LCR_reg)
    rand uvm_reg_field WL;
    rand uvm_reg_field STP;
    rand uvm_reg_field PE;
    rand uvm_reg_field EP;
    rand uvm_reg_field SP;
    rand uvm_reg_field BRK;
    rand uvm_reg_field DLAB;
    function new(string name = "LCR_reg");
      super.new(name, 8, UVM_CVR_ALL);
    endfunction
    virtual function void build();
      WL = uvm_reg_field::type_id::create("WL");
      STP = uvm_reg_field::type_id::create("STP");
      PE = uvm_reg_field::type_id::create("PE");
      EP = uvm_reg_field::type_id::create("EP");
      SP = uvm_reg_field::type_id::create("SP");
      BRK = uvm_reg_field::type_id::create("BRK");
      DLAB = uvm_reg_field::type_id::create("DLAB");
      WL.configure(this, 2, 0, "RW", 0, 'h3, 1, 0, 0);
      STP.configure(this, 1, 2, "RW", 0, 'h0, 1, 0, 0);
      PE.configure(this, 1, 3, "RW", 0, 'h0, 1, 0, 0);
      EP.configure(this, 1, 4, "RW", 0, 'h0, 1, 0, 0);
      SP.configure(this, 1, 5, "RW", 0, 'h0, 1, 0, 0);
      BRK.configure(this, 1, 6, "RW", 0, 'h0, 1, 0, 0);
      DLAB.configure(this, 1, 7, "RW", 0, 'h0, 1, 0, 0);
    endfunction
  endclass

  class MCR_reg extends uvm_reg;
    `uvm_object_utils(MCR_reg)
    rand uvm_reg_field DTR;
    rand uvm_reg_field RTS;
    rand uvm_reg_field OUT1;
    rand uvm_reg_field OUT2;
    rand uvm_reg_field LBACK;
    rand uvm_reg_field unused;

    function new(string name = "MCR_reg");
      super.new(name, 8, UVM_CVR_ALL);
    endfunction
    virtual function void build();
      DTR = uvm_reg_field::type_id::create("DTR");
      RTS = uvm_reg_field::type_id::create("RTS");
      OUT1 = uvm_reg_field::type_id::create("OUT1");
      OUT2 = uvm_reg_field::type_id::create("OUT2");
      LBACK = uvm_reg_field::type_id::create("LBACK");
      unused = uvm_reg_field::type_id::create("unused");
      DTR.configure(this, 1, 0, "RW", 0, 'h0, 1, 0, 0);
      RTS.configure(this, 1, 1, "RW", 0, 'h0, 1, 0, 0);
      OUT1.configure(this, 1, 2, "RW", 0, 'h0, 1, 0, 0);
      OUT2.configure(this, 1, 3, "RW", 0, 'h0, 1, 0, 0);
      LBACK.configure(this, 1, 4, "RW", 0, 'h0, 1, 0, 0);
      unused.configure(this, 3, 5, "RW", 0, 'h0, 1, 0, 0);
    endfunction
  endclass

  class LSR_reg extends uvm_reg;
    `uvm_object_utils(LSR_reg)
    rand uvm_reg_field DR;
    rand uvm_reg_field OE;
    rand uvm_reg_field PE;
    rand uvm_reg_field FE;
    rand uvm_reg_field BI;
    rand uvm_reg_field TFE;
    rand uvm_reg_field TXE;
    rand uvm_reg_field RFE;

    function new(string name = "LSR_reg");
      super.new(name, 8, UVM_CVR_ALL);
    endfunction
    virtual function void build();
      DR = uvm_reg_field::type_id::create("DR");
      OE = uvm_reg_field::type_id::create("OE");
      PE = uvm_reg_field::type_id::create("PE");
      FE = uvm_reg_field::type_id::create("FE");
      BI = uvm_reg_field::type_id::create("BI");
      TFE = uvm_reg_field::type_id::create("TFE");
      TXE = uvm_reg_field::type_id::create("TXE");
      RFE = uvm_reg_field::type_id::create("RFE");
      DR.configure(this, 1, 0, "RO", 0, 'h0, 1, 0, 0);
      OE.configure(this, 1, 1, "RO", 0, 'h0, 1, 0, 0);
      PE.configure(this, 1, 2, "RO", 0, 'h0, 1, 0, 0);
      FE.configure(this, 1, 3, "RO", 0, 'h0, 1, 0, 0);
      BI.configure(this, 1, 4, "RO", 0, 'h0, 1, 0, 0);
      TFE.configure(this, 1, 5, "RO", 0, 'h1, 1, 0, 0);
      TXE.configure(this, 1, 6, "RO", 0, 'h1, 1, 0, 0);
      RFE.configure(this, 1, 7, "RO", 0, 'h0, 1, 0, 0);
    endfunction
  endclass

  class MSR_reg extends uvm_reg;
    `uvm_object_utils(MSR_reg)
    rand uvm_reg_field DCTS;
    rand uvm_reg_field DDSR;
    rand uvm_reg_field TERI;
    rand uvm_reg_field DDCD;
    rand uvm_reg_field CTS;
    rand uvm_reg_field DSR;
    rand uvm_reg_field RI;
    rand uvm_reg_field DCD;
    function new(string name = "MSR_reg");
      super.new(name, 8, UVM_CVR_ALL);
    endfunction
    virtual function void build();
      DCTS = uvm_reg_field::type_id::create("DCTS");
      DDSR = uvm_reg_field::type_id::create("DDSR");
      TERI = uvm_reg_field::type_id::create("TERI");
      DDCD = uvm_reg_field::type_id::create("DDCD");
      CTS = uvm_reg_field::type_id::create("CTS");
      DSR = uvm_reg_field::type_id::create("DSR");
      RI = uvm_reg_field::type_id::create("RI");
      DCD = uvm_reg_field::type_id::create("DCD");
      DCTS.configure(this, 1, 0, "RO", 0, 'h0, 1, 0, 0);
      DDSR.configure(this, 1, 1, "RO", 0, 'h0, 1, 0, 0);
      TERI.configure(this, 1, 2, "RO", 0, 'h0, 1, 0, 0);
      DDCD.configure(this, 1, 3, "RO", 0, 'h0, 1, 0, 0);
      CTS.configure(this, 1, 4, "RO", 0, 'h0, 1, 0, 0);
      DSR.configure(this, 1, 5, "RO", 0, 'h0, 1, 0, 0);
      RI.configure(this, 1, 6, "RO", 0, 'h0, 1, 0, 0);
      DCD.configure(this, 1, 7, "RO", 0, 'h0, 1, 0, 0);
    endfunction
  endclass

  class DIV1_reg extends uvm_reg;
    `uvm_object_utils(DIV1_reg)
    rand uvm_reg_field DIV1;
    function new(string name = "DIV1_reg");
      super.new(name, 8, UVM_CVR_ALL);
    endfunction
    virtual function void build();
      DIV1 = uvm_reg_field::type_id::create("DIV1");
      DIV1.configure(this, 8, 0, "RW", 0, 'h0, 1, 0, 0);
    endfunction
  endclass

  class DIV2_reg extends uvm_reg;
    `uvm_object_utils(DIV2_reg)
    rand uvm_reg_field DIV2;
    function new(string name = "DIV2_reg");
      super.new(name, 8, UVM_CVR_ALL);
    endfunction
    virtual function void build();
      DIV2 = uvm_reg_field::type_id::create("DIV2");
      DIV2.configure(this, 8, 0, "RW", 0, 'h0, 1, 0, 0);
    endfunction
  endclass

  class apb_uart_rgm extends uvm_reg_block;
    `uvm_object_utils(apb_uart_rgm)
    rand txd_reg txd;
    rand rxd_reg rxd;
    rand IER_reg IER;
    rand IIR_reg IIR;
    rand FCR_reg FCR;
    rand LCR_reg LCR;
    rand MCR_reg MCR;
    rand LSR_reg LSR;
    rand MSR_reg MSR;
    rand DIV1_reg DIV1;
    rand DIV2_reg DIV2;
    uvm_reg_map map;
    function new(string name = "apb_uart_rgm");
      super.new(name, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      txd = txd_reg::type_id::create("txd");
      txd.configure(this);
      txd.build();
      rxd = rxd_reg::type_id::create("rxd");
      rxd.configure(this);
      rxd.build();
      IER = IER_reg::type_id::create("IER");
      IER.configure(this);
      IER.build();
      IIR = IIR_reg::type_id::create("IIR");
      IIR.configure(this);
      IIR.build();
      FCR = FCR_reg::type_id::create("FCR");
      FCR.configure(this);
      FCR.build();
      LCR = LCR_reg::type_id::create("LCR");
      LCR.configure(this);
      LCR.build();
      MCR = MCR_reg::type_id::create("MCR");
      MCR.configure(this);
      MCR.build();
      LSR = LSR_reg::type_id::create("LSR");
      LSR.configure(this);
      LSR.build();
      MSR = MSR_reg::type_id::create("MSR");
      MSR.configure(this);
      MSR.build();
      DIV1 = DIV1_reg::type_id::create("DIV1");
      DIV1.configure(this);
      DIV1.build();
      DIV2 = DIV2_reg::type_id::create("DIV2");
      DIV2.configure(this);
      DIV2.build();
      map = create_map("map", 'h0, 1, UVM_LITTLE_ENDIAN);
      map.add_reg(txd, 32'h00, "WO");
      map.add_reg(rxd, 32'h00, "RO");
      map.add_reg(IER, 32'h04, "RW");
      map.add_reg(IIR, 32'h8, "RO");
      map.add_reg(FCR, 32'h8, "WO");
      map.add_reg(LCR, 32'hc, "RW");
      map.add_reg(MCR, 32'h10, "RW");
      map.add_reg(LSR, 32'h14, "RO");
      map.add_reg(MSR, 32'h18, "RO");
      map.add_reg(DIV1, 32'h1c, "RW");
      map.add_reg(DIV2, 32'h20, "RW");

      add_hdl_path( .path( "uart_tb.DUT.control" ) );
      IER.add_hdl_path_slice( .name( "IER" ), .offset( 0 ), .size( 8 ) );
      IIR.add_hdl_path_slice( .name( "IIR" ), .offset( 0 ), .size( 8 ) );
      FCR.add_hdl_path_slice( .name( "FCR" ), .offset( 0 ), .size( 8 ) );
      LCR.add_hdl_path_slice( .name( "LCR" ), .offset( 0 ), .size( 8 ) );
      MCR.add_hdl_path_slice( .name( "MCR" ), .offset( 0 ), .size( 8 ) );
      LSR.add_hdl_path_slice( .name( "LSR" ), .offset( 0 ), .size( 8 ) );
      DIV1.add_hdl_path_slice( .name( "DIV1" ), .offset( 0 ), .size( 8 ) );
      DIV2.add_hdl_path_slice( .name( "DIV2" ), .offset( 0 ), .size( 8 ) );
      lock_model();
    endfunction
  endclass

endpackage
