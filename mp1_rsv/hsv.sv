// hsv colors

module top(
    input clk,
    output logic RGB_R,    // Red channel
    output logic RGB_G,    // Green channel
    output logic RGB_B     // Blue channel
);
    int counter = 0;
    int stage = 0;
    parameter INTERVAL = 2000000;

    reg [2:0] LEDS;

    initial begin
        LEDS = 3'b111;
        counter = 0;
        stage = 0;
    end

    always @(posedge clk) begin
        counter += 1;
        if (counter == INTERVAL) begin
            counter = 0;
            if (stage > 5)
                stage = 0;

            if (stage == 0)
                LEDS <= 3'b011; // Red
            if (stage == 1)
                LEDS <= 3'b001; // Yellow
            if (stage == 2)
                LEDS <= 3'b101; // Green
            if (stage == 3)
                LEDS <= 3'b100; // Cyan
            if (stage == 4)
                LEDS <= 3'b110; // Blue
            if (stage == 5)
                LEDS <= 3'b010; // Magenta

            stage += 1;
        end
    end

    assign RGB_R = LEDS[2];
    assign RGB_G = LEDS[1];
    assign RGB_B = LEDS[0];

endmodule
