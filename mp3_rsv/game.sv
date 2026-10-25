

module game #(
    parameter STEP_CYCLES = 3000000, // 4 iterations per second
    parameter INIT_FILE   = "initial.memh"
)(
    input logic clk,
    input logic [63:0] predator_next, // predator's next state
    output logic [63:0] board = 64'd0,  // one dimensional, (row, col) = rowNum * 8 + col
    output logic [63:0] next_board, // this color's next state
    output logic ready = 1'b0 // dictates whether or not the initial state is loaded
);
    // skip block RAM since it's only 8 bits
    logic [7:0] seed [0:7];
    initial $readmemh(INIT_FILE, seed);

    logic [3:0] load_index = 4'd0;

    // defines variables (row and column) used strictly as loop iterator

    generate
        for (genvar r = 0; r < 8; r++) begin: row
            for (genvar c = 0; c < 8; c++) begin: col
                // mod operator allows the game to wrap around the edges
                localparam above = (r + 7) % 8;
                localparam below = (r + 1) % 8;
                localparam right = (c + 1) % 8;
                localparam left = (c + 7) % 8;

                // finds the number of live neighbors
                wire [3:0] n = board[above*8 + left] + board[above*8 + c] + board[above*8 + right]
                             + board[r*8     + left]                      + board[r*8     + right]
                             + board[below*8 + left] + board[below*8 + c] + board[below*8 + right];

                // only alive if has 3 neighbors (dead or alive) or IS alive with two neighbors
                // must be dead in all other cases
                assign next_board[r*8 + c] = (n == 4'd3) | (board[r*8 + c] & ( n == 4'd2));
            end
        end

    endgenerate

    logic [31:0] timer = 32'd0;

    always_ff @(posedge clk) begin
        // if it's not ready, keep loading in the initial state
        if (!ready) begin
            // equivalent to load row * 8 (shifting)
            // goes across the whole row, from start to start + 8
            board[{load_index[2:0], 3'b000} +: 8] <= seed[load_index[2:0]];

            // if we've reached the end of the load index, set state to ready
            if (load_index == 4'd7)
                ready <= 1'b1;

            // if not, increment load_index
            else
                load_index <= load_index + 1;

        // if state is ready, count the timer until .25 second and update board
        // predation implemented here so there's no overlap
        end else begin
            // reset timer, set next board state
            if (timer == STEP_CYCLES - 1) begin
                timer <= 32'd0;
                board <= next_board & ~predator_next;

            // increment timer
            end else begin
                timer <= timer + 1;
            end
        end
    end
endmodule
