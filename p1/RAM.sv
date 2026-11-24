`define DATA_WIDTH 32

module RAM #(
    parameter int MEMORY_SIZE = 1024 // 4 iterations per second
)(
    input logic i_clk,

    // write enable signal
    input logic i_we,

    // data to be written
    input logic [`DATA_WIDTH-1:0] i_data,

    // byte address from program counter
    input logic [$clog2(MEMORY_SIZE)-1:0] i_addr,

    // data being read
    output logic [`DATA_WIDTH-1:0] o_data
);
    // 1024 words of 32 bit length
    logic [`DATA_WIDTH-1:0] memory [MEMORY_SIZE];

    // zero all 1024 words so we avoid a starting value of x for all
    initial begin
        for (int i = 0; i < MEMORY_SIZE; i++)
            memory[i] = '0;
    end

    always @(posedge i_clk) begin

        // only write data if the write enable signal is activated
        if (i_we)
            memory[i_addr] <= i_data;

    end

    // if write enable false, just read data
    assign o_data = memory[i_addr];

endmodule
