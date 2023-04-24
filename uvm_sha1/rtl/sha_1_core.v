//=====================================
// module name: sha_1_core
// author: fyb
// describe: 
//  input         
//          clk
//          rst_n
//          data_in
//          valid_in
//          last_block
//  output            
//          in_ready
//          hash
//          valid_out
//=====================================

module sha_1_core (
    input         clk,
    input         rst_n,
    input [63:0]  data_in,
    input         valid_in,
    input         last_block,

    output reg          in_ready,
    output reg          pad_in_ready,
    output reg [159:0]  hash,
    output reg          valid_out
);
integer i;
reg [31:0]  words [15:0];
reg [ 3:0]  load_cnt;
reg         words_gen_en;
reg [31:0]  words_gen_0, words_gen_temp_0;
reg [31:0]  words_gen_1, words_gen_temp_1;
reg         cala_en;
reg [ 6:0]  cala_cnt;
reg [31:0]  A, B, C, D, E;
reg [31:0]  H0, H1, H2, H3, H4;
reg [31:0]  f_A, f_B, k;
reg [31:0]  A_temp,B_temp;
reg [159:0] hash_reg;
reg         last_block_reg;
reg [31:0]  S30_B;
//------------------------------ 
// Generate enable signal
//--------------------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        load_cnt     <= 4'b0;
        words_gen_en <= 1'b0;
        cala_en      <= 1'b0;
        cala_cnt     <= 7'd2;
        valid_out    <= 1'b0;
        in_ready     <= 1'b1;
    end
    else begin
        if(valid_in)begin  
            if (load_cnt >= 4'd12) begin
                pad_in_ready  <= 1'b0; 
            end
            else begin
                pad_in_ready  <= 1'b1;
            end

            if (load_cnt >= 4'd10) begin
                in_ready  <= 1'b0; 
            end
            else begin
                in_ready  <= 1'b1;
            end
            
            if (load_cnt == 4'd14) begin
                load_cnt     <= 4'b0;
                words_gen_en <= 1'b1;
                cala_en      <= 1'b1;
                if(last_block)begin
                    last_block_reg <= 1'b1;
                end
                else begin
                    last_block_reg <= 1'b0; 
                end
            end
            else begin
                load_cnt     <= load_cnt + 2'd2;
                words_gen_en <= 1'b0;
                cala_en      <= 1'b0;
                last_block_reg <= 1'b0; 
            end
        end
        else if(words_gen_en)begin
            if (cala_cnt == 7'd80) begin
                cala_cnt     <= 7'd2;
                words_gen_en <= 1'b0;
                cala_en      <= 1'b0;
                valid_out    <= 1'b1 & last_block_reg;
                in_ready     <= 1'b1; 
                pad_in_ready  <= 1'b1;
            end
            else begin
                cala_cnt     <= cala_cnt + 2'd2;
                words_gen_en <= 1'b1;
                cala_en      <= 1'b1;
                valid_out    <= 1'b0;
                in_ready     <= 1'b0; 
                pad_in_ready  <= 1'b0;
            end
        end
        else begin
            load_cnt     <= 4'b0;
            words_gen_en <= 1'b0;
            cala_en      <= 1'b0;
            cala_cnt     <= 7'd2;
            valid_out    <= 1'b0;
            in_ready     <= 1'b1;
            pad_in_ready <= 1'b1;
        end
    end
end

//=================================
// Cache word data
//=================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        for(i = 0; i < 16 ; i = i + 1)begin
            words[i] <= 64'b0;
        end
    end
    else begin
        if(valid_in)begin 
            words[load_cnt + 1] <= data_in[31:0];
            words[load_cnt] <= data_in[63:32];
        end
        else if(words_gen_en)begin
            words[15] <= words_gen_1;
            words[14] <= words_gen_0;
            for(i = 0; i < 14 ; i = i + 1)begin
                words[i] <= words[i+2];
            end
        end
    end
end

// always @(posedge clk ) begin
//     if(cala_cnt == 7'd80 && last_block_reg)begin
//         hash <= hash_reg;
//     end
//     else begin
//         hash <= 160'd0;
//     end
// end

//=================================
// generate other words
//=================================
always @(*) begin
    words_gen_temp_0 = words[13] ^ words[8] ^ words[2] ^ words[0];
    words_gen_0 = {words_gen_temp_0[30:0], words_gen_temp_0[31]};
    words_gen_temp_1 = words[14] ^ words[9] ^ words[3] ^ words[1];
    words_gen_1 = {words_gen_temp_1[30:0], words_gen_temp_1[31]};
end

//================================
// Calculate the hash value
//===================================
always @(posedge clk ) begin
    if (!rst_n) begin
        H0 = 32'h67452301; 
        H1 = 32'hEFCDAB89;
        H2 = 32'h98BADCFE;
        H3 = 32'h10325476;
        H4 = 32'hC3D2E1F0;
        A = H0; B = H1;
        C = H2; D = H3;
        E = H4;
        hash_reg = {H0, H1, H2, H3, H4};
    end
    else if(cala_en) begin
        S30_B = {B[1:0], B[31:2]};
        if(cala_cnt == 7'd2)begin
            A = H0; B = H1;
            C = H2; D = H3;
            E = H4;
        end
        if(cala_cnt <= 7'd20) begin
            k = 32'h5A827999;
            f_B = (B & C) | ((~B) & D);
            f_A = (A & S30_B) | ((~A) & C);
        end 
        else if(cala_cnt > 7'd40 && cala_cnt <= 7'd60) begin
            k = 32'h8F1BBCDC;
            f_B = (B & C) | (B & D) | (C & D);
            f_A = (A & S30_B) | (A & C) | (S30_B & C);
        end
        else begin
            if(cala_cnt <= 7'd40 )
                k = 32'h6ED9EBA1;
            else
                k = 32'hCA62C1D6;
            f_B = B ^ C ^ D;
            f_A = A ^ S30_B ^ C;
        end
        B_temp = {A[26:0], A[31:27]} + f_B + E + words[0] + k;
        A_temp = {B_temp[26:0], B_temp[31:27]} + f_A+ D + words[1] + k ;
        E = C;
        D = S30_B;
        C = {A[1:0], A[31:2]};
        B = B_temp;
        A = A_temp;
        if (cala_cnt == 7'd80) begin
            H0 = H0 + A;
            H1 = H1 + B;
            H2 = H2 + C;
            H3 = H3 + D;
            H4 = H4 + E;
        end
        hash = {H0, H1, H2, H3, H4};
    end
    else begin
        if(last_block_reg) begin
            H0 = 32'h67452301; 
            H1 = 32'hEFCDAB89;
            H2 = 32'h98BADCFE;
            H3 = 32'h10325476;
            H4 = 32'hC3D2E1F0;
        end
        else begin
            H0 = H0;
            H1 = H1;
            H2 = H2;
            H3 = H3;
            H4 = H4;
        end
        A = H0; B = H1;
        C = H2; D = H3;
        E = H4;
        hash = {H0, H1, H2, H3, H4};
    end
end

endmodule
