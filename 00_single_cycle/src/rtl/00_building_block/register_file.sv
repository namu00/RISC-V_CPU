module reg_file(
    input               clk,
    input               we,
    input   [4  : 0]    rs1,
    input   [4  : 0]    rs2,
    input   [4  : 0]    rd_addr,
    input   [4  : 0]    rd_data,
    
    output  [31 : 0]    rd1,
    output  [31 : 0]    rd2
);

//register memory
reg [31:0] mem [0:31];

//memory output
assign rd1 = (rs1 == 5'h0) ? 32'h0 : mem[rs1];
assign rd2 = (rs1 == 5'h0) ? 32'h0 : mem[rs2];

//register-file initialize logic
initial begin
    integer init_idx;
    for(init_idx = 0; init_idx < 32; init_idx = init_idx + 1)begin
        mem[init_idx] = 0;
    end
end

//rd write logic
genvar idx;
generate
    for(idx = 1; idx < 32; idx = idx + 1)begin: REG_FILE
        always @(posedge clk)begin
            if((idx == rd_addr) && (we))begin
                mem[idx] <= rd_data;
            end
        end
    end
endgenerate

endmodule