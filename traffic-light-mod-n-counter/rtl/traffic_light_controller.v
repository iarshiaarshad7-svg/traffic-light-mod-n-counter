// Two-road traffic-light controller using a four-state FSM
// and a programmable Mod-N counter.

module traffic_light_controller #(
    parameter WIDTH = 8,
    parameter GREEN_TICKS = 5,
    parameter YELLOW_TICKS = 2
)(
    input wire clk,
    input wire reset,

    output reg ns_red,
    output reg ns_yellow,
    output reg ns_green,

    output reg ew_red,
    output reg ew_yellow,
    output reg ew_green
);

    localparam [1:0] NS_GREEN  = 2'b00;
    localparam [1:0] NS_YELLOW = 2'b01;
    localparam [1:0] EW_GREEN  = 2'b10;
    localparam [1:0] EW_YELLOW = 2'b11;

    reg [1:0] state;
    reg [WIDTH-1:0] phase_limit;
    wire [WIDTH-1:0] tick_count;
    wire phase_done;
    wire counter_clear;

    // The counter is cleared on reset and at each phase transition.
    assign counter_clear = reset || phase_done;

    mod_n_counter #(
        .WIDTH(WIDTH)
    ) phase_timer (
        .clk(clk),
        .reset(reset),
        .clear(counter_clear),
        .enable(1'b1),
        .limit(phase_limit),
        .count(tick_count),
        .terminal(phase_done)
    );

    // Select the duration for the current phase.
    always @(*) begin
        if (state == NS_GREEN || state == EW_GREEN)
            phase_limit = GREEN_TICKS;
        else
            phase_limit = YELLOW_TICKS;
    end

    // State register.
    always @(posedge clk) begin
        if (reset) begin
            state <= NS_GREEN;
        end else if (phase_done) begin
            case (state)
                NS_GREEN:  state <= NS_YELLOW;
                NS_YELLOW: state <= EW_GREEN;
                EW_GREEN:  state <= EW_YELLOW;
                EW_YELLOW: state <= NS_GREEN;
                default:   state <= NS_GREEN;
            endcase
        end
    end

    // Decode the current state into traffic-light outputs.
    always @(*) begin
        ns_red = 1'b0;
        ns_yellow = 1'b0;
        ns_green = 1'b0;
        ew_red = 1'b0;
        ew_yellow = 1'b0;
        ew_green = 1'b0;

        case (state)
            NS_GREEN: begin
                ns_green = 1'b1;
                ew_red = 1'b1;
            end

            NS_YELLOW: begin
                ns_yellow = 1'b1;
                ew_red = 1'b1;
            end

            EW_GREEN: begin
                ns_red = 1'b1;
                ew_green = 1'b1;
            end

            EW_YELLOW: begin
                ns_red = 1'b1;
                ew_yellow = 1'b1;
            end

            default: begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end
        endcase
    end

endmodule
