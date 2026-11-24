`define INSTRUCTION_WIDTH 32

module instruction_memory #(
    parameter int MEMORY_SIZE = 1024 // 4 iterations per second
)(
    // byte address from program counter
    input logic [$clog2(MEM_SIZE)-1:0] i_addr,

    // the instruction stored at that address
    output logic [`INSTRUCTION_WIDTH-1:0] inst
);
    // 1024 words of 32 bit length
    logic [`INSTRUCTION_WIDTH-1:0] memory [MEMORY_SIZE];

    // zero all 1024 words so we avoid a starting value of x for all
    initial begin
        for (int i = 0; i < MEMORY_SIZE; i++)
            memory[i] = '0;

        $readmemh("program.h", memory);
    end

    // divide the byte address by 4 to get the word number
    always_comb inst = memory[i_addr >> 2];

endmodule
