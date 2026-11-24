// Programmable Mod-N counter
// Counts from 0 to limit-1, then returns to 0.
// reset and clear are active-high synchronous controls.

module mod_n_counter #(
    parameter WIDTH = 8
)(
    input wire clk,
    input wire reset,
    input wire clear,
    input wire enable,
    input wire [WIDTH-1:0] limit,
    output reg [WIDTH-1:0] count,
    output wire terminal
);

    // terminal is high on the cycle where count is limit-1.
    // A limit of zero is treated as 1 to avoid underflow.
    assign terminal = (count == ((limit == 0) ? {{(WIDTH-1){1'b0}}, 1'b0} : limit - 1'b1));

    always @(posedge clk) begin
        if (reset || clear) begin
            count <= {WIDTH{1'b0}};
        end else if (enable) begin
            if (limit <= 1 || terminal)
                count <= {WIDTH{1'b0}};
            else
                count <= count + 1'b1;
        end
    end

endmodule
