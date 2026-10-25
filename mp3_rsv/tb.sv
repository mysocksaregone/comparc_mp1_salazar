`include "game.sv"
`timescale 10ns/10ns

// Testbench with two independent parts:
//   Part 1: game + memory   -> checks seed loading and the Life rules
//   Part 2: controller + ws2812b -> checks the bit stream sent to the LEDs
// Run: iverilog -g2012 -o sim tb.sv game.sv controller.sv ws2812b.sv memory.sv
//      vvp sim
//      gtkwave wave.vcd
module tb # (
    parameter RED_INIT_FILE = "red_initial.memh",
    parameter BLUE_INIT_FILE = "blue_initial.memh",
    parameter GREEN_INIT_FILE = "green_initial.memh"

);
    logic clk = 0;
    always #4 clk = ~clk;

    logic [63:0] board_r, board_g, board_b;
    logic [63:0] next_r, next_g, next_b;
    logic        ready_r, ready_g, ready_b;

    game #(.STEP_CYCLES(20), .INIT_FILE(RED_INIT_FILE))   red (.clk(clk), .predator_next(next_b),
                                            .board(board_r), .next_board(next_r), .ready(ready_r));

    game #(.STEP_CYCLES(20), .INIT_FILE(BLUE_INIT_FILE))  blue (.clk(clk), .predator_next(next_g),
                                             .board(board_b), .next_board(next_b), .ready(ready_b));

    game #(.STEP_CYCLES(20), .INIT_FILE(GREEN_INIT_FILE)) green (.clk(clk), .predator_next(next_r),
                                            .board(board_g), .next_board(next_g), .ready(ready_g));

    // each board split into 8 rows
    wire [7:0] red_row [0:7];
    wire [7:0] blue_row [0:7];
    wire [7:0] green_row [0:7];

    genvar i;

    // save colored boards by rows
    generate
        for (i = 0; i < 8; i++) begin : rows
            assign red_row[i] = board_r[i*8 +: 8];
            assign green_row[i] = board_g[i*8 +: 8];
            assign blue_row[i] = board_b[i*8 +: 8];
        end
    endgenerate

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
        #20000
        $finish;
    end


endmodule