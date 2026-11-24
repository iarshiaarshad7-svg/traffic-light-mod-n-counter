`timescale 1ns/1ps

module tb_traffic_light_controller;

    reg clk = 0;
    reg reset = 1;

    wire ns_red, ns_yellow, ns_green;
    wire ew_red, ew_yellow, ew_green;

    traffic_light_controller #(
        .WIDTH(8),
        .GREEN_TICKS(3),
        .YELLOW_TICKS(2)
    ) dut (
        .clk(clk),
        .reset(reset),
        .ns_red(ns_red),
        .ns_yellow(ns_yellow),
        .ns_green(ns_green),
        .ew_red(ew_red),
        .ew_yellow(ew_yellow),
        .ew_green(ew_green)
    );

    always #5 clk = ~clk;

    task check_safe;
        begin
            // Both roads must never show green simultaneously.
            if (ns_green && ew_green) begin
                $display("FAIL: both roads are green");
                $finish;
            end
            // A road must not show red and green simultaneously.
            if ((ns_red && ns_green) || (ew_red && ew_green)) begin
                $display("FAIL: conflicting light outputs");
                $finish;
            end
        end
    endtask

    initial begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, tb_traffic_light_controller);

        repeat (2) @(posedge clk);
        reset = 0;

        // Observe several complete phase changes.
        repeat (24) begin
            @(posedge clk);
            #1;
            check_safe;
            $display("NS(RYG)=%b%b%b  EW(RYG)=%b%b%b",
                     ns_red, ns_yellow, ns_green,
                     ew_red, ew_yellow, ew_green);
        end

        $display("PASS: Traffic-light controller test completed.");
        $finish;
    end

endmodule
