
module controller #(
    // defines the number of frames and pause between frames
    parameter LATCH_CYCLES = 1200,
    parameter RED_GRB   = 24'h00_18_00,
    parameter GREEN_GRB = 24'h18_00_00,
    parameter BLUE_GRB  = 24'h00_00_18

)(
    input logic clk,
    input  logic [63:0] board_r,
    input  logic [63:0] board_g,
    input  logic [63:0] board_b,
    input logic shift,
    output logic transmit,
    output logic serial_in
);
    // defining the current led value
    logic [6:0] led_idx = 7'd0;

    // current color that we're on
    logic [4:0] bit_idx = 5'd0;

    // countsclock cycles during latch pause between frames
    logic [10:0] latch_cnt = 11'd0;

    // defines if a frame is being transmitted
    logic sending = 1'd0;

    // outputs transmit according to sending
    assign transmit = sending;

    logic [23:0] pixel;

    always_comb begin
        // ignore the final slot of 64th slot
        // checks whether or not the led of each pixel is
        // on, sets to respective color if so
        if (led_idx < 7'd64 && board_r[led_idx[5:0]])
            pixel = RED_GRB;
        else if (led_idx < 7'd64 && board_g[led_idx[5:0]])
            pixel = GREEN_GRB;
        else if (led_idx < 7'd64 && board_b[led_idx[5:0]])
            pixel = BLUE_GRB;
        else
            // set fake or dead pixel to 0 (fake pixel 64)
            pixel = 24'd0;
    end

    // LEDs are chained, each grabs first 24 bits
    // assigns current pixel bit MSB first
    assign serial_in = pixel[23 - bit_idx];


    always_ff @(posedge clk) begin
        if (!sending) begin
            // sets sending to true,  resets latch count
            if (latch_cnt == LATCH_CYCLES - 1) begin
                sending <= 1'b1;
                latch_cnt <= 11'd0;
            end else begin

                // increment latch count
                latch_cnt <= latch_cnt + 1;
            end

        // if shifting has begun
        end else if (shift) begin
            // currently on unused bit, frame is over
            if (led_idx == 7'd64) begin
                sending <= 1'b0; // stop sending to begin latch pause
                led_idx <= 7'd0; // reset led index
                bit_idx <= 5'd0; // reset bit index

                // if the current LED is over...
            end else if (bit_idx == 5'd23) begin

                // reset current bit index
                bit_idx <= 5'd0;

                // increment led index
                led_idx <= led_idx + 1;

            end else begin
                // increment current bit index
                bit_idx <= bit_idx + 1;
            end
        end
    end

endmodule
