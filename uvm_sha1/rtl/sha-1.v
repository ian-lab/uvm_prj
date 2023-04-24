//=======================================
// module name: sha-1
// author: fan yingbao
// input
//      clk
//      rst_n
//      data_in 
//      valid_in    
// output
//      hash
//      valid_out
//      in_ready;
//=======================================
module sha_1 (
    input          clk,
    input          rst_n,
    input  [63:0]  data_in,
    input          valid_in,

    output [159:0] hash,
    output         valid_out,
    output         in_ready
);

wire [63:0] data_pad;
wire        pad_valid_out; 
wire        last_block;
wire        pad_in_ready;

message_padder  u_message_padder (  
    .clk         ( clk           ),
    .rst_n       ( rst_n         ),
    .data_in     ( data_in       ),
    .valid_in    ( valid_in      ),
    .out_ready   ( pad_in_ready  ),

    .valid_out   ( pad_valid_out ),
    .data_pad    ( data_pad      ),
    .last_block  ( last_block    )
);

sha_1_core  u_sha_1_core (
    .clk          ( clk           ),
    .rst_n        ( rst_n         ),
    .data_in      ( data_pad      ),
    .valid_in     ( pad_valid_out ),
    .last_block   ( last_block    ),

    .in_ready     ( in_ready      ),
    .pad_in_ready ( pad_in_ready  ),
    .hash         ( hash          ),
    .valid_out    ( valid_out     )
);

endmodule