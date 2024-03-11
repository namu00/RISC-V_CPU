module sram_model#(
    parameter MIF_HEX    = "",
    parameter ADDR_WIDTH = 12,
    parameter BYTE_WIDTH = 8,
    parameter WORD_WIDTH = 32,
    parameter BYTES = (WORD_WIDTH / BYTE_WIDTH)
)(
    input                       clk,
    input   [ADDR_WIDTH-1 : 0]  addr,   //ADDRESS
    input   [BYTES-1 : 0]       be,     //BYTE-ENABLE
    input                       we,     //WRITE-ENABLE
    input   [WORD_WIDTH-1 : 0]  wdata,  //WRITE-DATA
    output  [WORD_WIDTH-1 : 0]  rdata   //READ-DATA
);

reg [BYTES-1 : 0][ BYTE_WIDTH-1 : 0] mem [ADDR_WIDTH-1 : 0];
reg [WORD_WIDTH-1 : 0] rdata_buffer;

//memory initialize logic
`ifdef SIM
    integer idx;
    integer mem_size;
    initial begin
        mem_size = (1 << ADDR_WIDTH);
        if(MIF_HEX != "")begin
            $readmemh(MIF_HEX, mem);
        end

        else begin
            for(idx = 0; idx < mem_size; idx = idx + 1)begin
                mem[idx] = 0;
            end
        end
    end
`endif

//memory write logic
always@(posedge clk)begin
    if(we)begin
        if(be[0])   mem[addr][0] <= wdata[7:0];
        if(be[1])   mem[addr][1] <= wdata[15:8];
        if(be[2])   mem[addr][2] <= wdata[23:16];
        if(be[3])   mem[addr][3] <= wdata[31:24];
    end
end

//memory read logic
always @(posedge clk)begin
    rdata_buffer <= mem[addr];
end

//memory output
assign rdata = rdata_buffer;    
endmodule