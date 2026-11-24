# Traffic-Light Controller + Mod-N Counter

A beginner-friendly digital logic capstone project written in **Verilog HDL**.

The project models a two-road intersection:
- North-South (NS) traffic
- East-West (EW) traffic

The controller cycles through four safe phases:

1. NS Green, EW Red
2. NS Yellow, EW Red
3. NS Red, EW Green
4. NS Red, EW Yellow

A reusable **programmable Mod-N counter** measures how long the controller stays in each phase. The counter is cleared whenever the controller changes phase.

## Repository contents

```text
traffic-light-mod-n-counter/
├── rtl/
│   ├── mod_n_counter.v
│   └── traffic_light_controller.v
├── testbench/
│   ├── tb_mod_n_counter.v
│   └── tb_traffic_light_controller.v
├── docs/
│   └── DESIGN_DOCUMENT.md
└── README.md
```

## Features

- Four-state finite state machine (FSM).
- Separate reusable Mod-N counter.
- Different programmable durations for green and yellow lights.
- Active-high synchronous reset.
- Testbenches for both modules.
- No FPGA board or external hardware is required to simulate the project.

## Default timing

The default parameters are deliberately small so simulation finishes quickly:
- Green duration: 5 clock cycles
- Yellow duration: 2 clock cycles

These are **simulation tick counts**, not real-world seconds. For a real traffic signal, choose tick counts based on the clock frequency and required time.

## Run the simulation

Install Icarus Verilog and GTKWave if they are not already installed.

From the repository root, run:

### Test the Mod-N counter

```bash
iverilog -o counter_test rtl/mod_n_counter.v testbench/tb_mod_n_counter.v
vvp counter_test
```

Expected final message:

```text
PASS: Mod-N counter test completed.
```

### Test the traffic-light controller

```bash
iverilog -o traffic_test rtl/mod_n_counter.v rtl/traffic_light_controller.v testbench/tb_traffic_light_controller.v
vvp traffic_test
```

Expected final message:

```text
PASS: Traffic-light controller test completed.
```

The testbenches also create `.vcd` waveform files. To view a waveform:

```bash
gtkwave traffic_light.vcd
```

## Light output encoding

Each road has three output bits: Red, Yellow, Green.

| Signal | Meaning |
|---|---|
| `ns_red` | North-South red light |
| `ns_yellow` | North-South yellow light |
| `ns_green` | North-South green light |
| `ew_red` | East-West red light |
| `ew_yellow` | East-West yellow light |
| `ew_green` | East-West green light |

Only one road is allowed to have a green or yellow light at a time. The other road remains red.

## Customization

The controller has parameters:
- `GREEN_TICKS`: number of clock cycles for each green phase.
- `YELLOW_TICKS`: number of clock cycles for each yellow phase.
- `WIDTH`: width of the counter and phase-duration values.

Example instantiation:

```verilog
traffic_light_controller #(
    .GREEN_TICKS(8),
    .YELLOW_TICKS(3),
    .WIDTH(8)
) traffic_system (
    .clk(clk),
    .reset(reset),
    .ns_red(ns_red),
    .ns_yellow(ns_yellow),
    .ns_green(ns_green),
    .ew_red(ew_red),
    .ew_yellow(ew_yellow),
    .ew_green(ew_green)
);
```

Make sure `WIDTH` is large enough to represent the selected tick counts.

## Project note

This is an educational simulation model, not a certified real-world traffic-control system. Real intersections require additional safety logic, fault detection, pedestrian handling, and hardware validation.
