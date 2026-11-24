`timescale 1ns/1ps

module tb_mod_n_counter;

    reg clk = 0;
    reg reset = 1;
    reg clear = 0;
    reg enable = 1;
    reg [3:0] limit = 4'd5;
    wire [3:0] count;
    wire terminal;

    mod_n_counter #(.WIDTH(4)) dut (
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .enable(enable),
        .limit(limit),
        .count(count),
        .terminal(terminal)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("mod_n_counter.vcd");
        $dumpvars(0, tb_mod_n_counter);

        repeat (2) @(posedge clk);
        reset = 0;

        // Check that the counter wraps for Mod-5.
        repeat (12) begin
            @(posedge clk);
            #1;
            if (count > 4) begin
                $display("FAIL: counter exceeded limit");
                $finish;
            end
        end

        if (count !== 4'd2) begin
            $display("FAIL: unexpected count after 12 enabled clocks: %0d", count);
            $finish;
        end

        clear = 1;
        @(posedge clk);
        #1;
        clear = 0;

        if (count !== 4'd0) begin
            $display("FAIL: clear did not reset the count");
            $finish;
        end

        $display("PASS: Mod-N counter test completed.");
        $finish;
    end

endmodule
