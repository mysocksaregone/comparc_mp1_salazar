`define DATA_WIDTH 32
`define NUM_OF_REGISTER 32

module register_file #(
    parameter int MEMORY_SIZE = 1024 // 4 iterations per second
)(
    input wire clk,
    input wire rst,  // allows us to clear all registers
    input wire we,

    // destination register
    input wire [$clog2(`NUM_OF_REGISTER)-1:0] dest_reg_addr, // number (0-31)
    input wire [`DATA_WIDTH-1:0] dest_reg_data, // value to write into it

    // source register numbers
    input wire [$clog2(`NUM_OF_REGISTER)-1:0] i_rs1_addr,
    input wire [$clog2(`NUM_OF_REGISTER)-1:0] i_rs2_addr,

    // values in source registers 1 and 2
    output wire [`DATA_WIDTH-1:0] o_rs1,
    output wire [`DATA_WIDTH-1:0] o_rs2
);

    logic [`DATA_WIDTH-1:0] registers [`NUM_OF_REGISTER];

    initial begin
        // zero everything
        for (int i = 0; i < `NUM_OF_REGISTER; i++)
            registers[i] = '0;
    end

    // apply register set and reset if we
    always_ff @(posedge clk) begin
        if (rst)
            for (int i = 0; i < `NUM_OF_REGISTER; i++)
                registers[i] <= '0;

        // remember that x0 will always be 0
        else if (we && dest_reg_addr != 0) begin
            registers[dest_reg_addr] <= dest_reg_data;
        end
    end

    // assign values from registers and account for x0 case
    assign o_rs1 = (i_rs1_addr == 0) ? '0 : registers[i_rs1_addr];
    assign o_rs2 = (i_rs2_addr == 0) ? '0 : registers[i_rs2_addr];

endmodule
