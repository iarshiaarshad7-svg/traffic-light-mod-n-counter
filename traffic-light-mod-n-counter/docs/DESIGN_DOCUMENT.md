# Design Document: Traffic-Light Controller + Mod-N Counter

## 1. Title

**Design and Simulation of a Two-Road Traffic-Light Controller Using a Mod-N Counter**

## 2. Objective

The objective is to design a digital traffic-light controller for a two-road intersection. A finite state machine (FSM) controls the sequence of red, yellow, and green lights. A programmable Mod-N counter determines the duration of each phase.

## 3. Problem statement

At a road intersection, traffic from one direction must be stopped while traffic from the other direction is allowed to move. The controller must change the signals in a fixed and safe order. The duration of each phase is measured using clock cycles.

## 4. Block-level architecture

The design contains two main blocks:

1. **Finite State Machine (FSM):** Selects the current traffic-light phase.
2. **Programmable Mod-N Counter:** Counts clock cycles for the active phase and signals when the phase duration is complete.

The FSM selects the counter limit:
- Green states use `GREEN_TICKS`.
- Yellow states use `YELLOW_TICKS`.

When the counter reaches `limit - 1`, the `phase_done` signal becomes high. The FSM advances to the next state, and the counter is cleared for the next phase.

## 5. State sequence

| State | North-South | East-West | Next state |
|---|---|---|---|
| NS_GREEN | Green | Red | NS_YELLOW |
| NS_YELLOW | Yellow | Red | EW_GREEN |
| EW_GREEN | Red | Green | EW_YELLOW |
| EW_YELLOW | Red | Yellow | NS_GREEN |

The sequence repeats continuously after reset is released.

## 6. State diagram (text representation)

```text
          +-----------+
          | NS_GREEN  |
          +-----------+
                |
                v
          +-----------+
          | NS_YELLOW |
          +-----------+
                |
                v
          +-----------+
          | EW_GREEN  |
          +-----------+
                |
                v
          +-----------+
          | EW_YELLOW |
          +-----------+
                |
                +-----------> back to NS_GREEN
```

## 7. Mod-N counter operation

A Mod-N counter counts from 0 to N-1 and then returns to 0.

For example, a Mod-5 counter follows this sequence:

```text
0 -> 1 -> 2 -> 3 -> 4 -> 0 -> ...
```

In this project, the counter is programmable. Its `limit` input determines the number of clock cycles in the current traffic phase.

The counter has:
- `clk`: clock input
- `reset`: synchronous reset
- `clear`: synchronous clear between phases
- `enable`: enables counting
- `limit`: selected count limit
- `count`: current count
- `terminal`: indicates that the current count has reached `limit - 1`

## 8. Design parameters

| Parameter | Default value | Purpose |
|---|---:|---|
| `WIDTH` | 8 | Width of counter |
| `GREEN_TICKS` | 5 | Duration of each green phase |
| `YELLOW_TICKS` | 2 | Duration of each yellow phase |

The small default values make simulation quick. They can be increased for a hardware implementation.

## 9. Algorithm

1. Start the clock.
2. Apply reset.
3. Set the FSM to `NS_GREEN`.
4. Set the counter to zero.
5. Select the duration according to the current state.
6. Increment the counter on each active clock edge.
7. When the counter reaches `limit - 1`, advance the FSM.
8. Clear the counter.
9. Decode the new state into the six traffic-light outputs.
10. Repeat the sequence continuously.

## 10. Verification and test cases

### Mod-N counter

| Test | Input / condition | Expected result |
|---|---|---|
| Reset | `reset = 1` | Count becomes 0 |
| Enable | `enable = 1`, limit = 5 | Count increments |
| Terminal count | Count reaches 4 | `terminal = 1` |
| Wraparound | Next enabled clock at terminal | Count returns to 0 |
| Clear | `clear = 1` | Count becomes 0 |

### Traffic-light controller

| Test | Expected result |
|---|---|
| Reset | NS Green, EW Red |
| After green duration | NS Yellow, EW Red |
| After yellow duration | NS Red, EW Green |
| After next green duration | NS Red, EW Yellow |
| After next yellow duration | Sequence returns to NS Green |
| Safety check | Both roads are never green together |

## 11. Expected result

The simulation should show the four traffic-light phases in the correct order. The Mod-N counter should count up to one less than its selected limit and then wrap to zero. The testbenches check counter operation and basic traffic-light safety conditions.

## 12. Applications

- Learning finite state machines.
- Understanding counters and timing circuits.
- Digital logic and sequential circuit design.
- Basic traffic-signal controller simulation.

## 13. Limitations and future improvements

- The design models only two roads.
- Pedestrian crossing signals are not included.
- Emergency-vehicle priority is not included.
- The project is a simulation model and is not certified for real traffic use.

Possible future improvements include pedestrian controls, emergency priority, vehicle sensors, and FPGA implementation.

## 14. Conclusion

The project demonstrates how a finite state machine and a programmable Mod-N counter can work together to control a traffic-light sequence. The FSM selects the signal phase, while the counter measures the duration of that phase. Verilog testbenches are used to verify the operation.
