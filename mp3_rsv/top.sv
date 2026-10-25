`include "game.sv"
`include "ws2812b.sv"
`include "controller.sv"

// Variant 4: Rock-Paper-Scissors with color
// red eats green, green eats blue, blue eats red
// define predators of each colored game in instantiation of game modules

module top # (
    parameter RED_INIT_FILE = "red_initial.memh",
    parameter BLUE_INIT_FILE = "blue_initial.memh",
    parameter GREEN_INIT_FILE = "green_initial.memh"

)(
    input  logic clk,
    output wire _48b

);
    logic [63:0] board_r, board_g, board_b;

    // the results of each game of life, before predation
    // used to adjust the positions of other colors + implement predation rules
    logic [63:0] next_r,  next_g,  next_b;
    logic        ready_r, ready_g, ready_b;
    logic shift, transmit, serial_in;

    game #(.INIT_FILE(RED_INIT_FILE))   red (.clk(clk), .predator_next(next_b), .board(board_r),
                                                            .next_board(next_r), .ready(ready_r));

    game #(.INIT_FILE(BLUE_INIT_FILE))  blue (.clk(clk), .predator_next(next_g), .board(board_b),
                                                            .next_board(next_b), .ready(ready_b));

    game #(.INIT_FILE(GREEN_INIT_FILE)) green (.clk(clk), .predator_next(next_r), .board(board_g),
                                                            .next_board(next_g), .ready(ready_g));

    controller   c1   (.clk(clk), .board_r(board_r), .board_g(board_g), .board_b(board_b),
                   .shift(shift), .transmit(transmit), .serial_in(serial_in));
    ws2812b      drv1  (.clk(clk), .serial_in(serial_in), .transmit(transmit),
                       .ws2812b_out(_48b), .shift(shift));

endmodule
