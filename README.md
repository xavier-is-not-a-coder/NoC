# 🌐 Hardware-Efficient Network-on-Chip (NoC) Router in VHDL

A highly modular, fully synthesizable VHDL implementation of a 2D-Mesh Network-on-Chip (NoC) Router. This architecture uses packet-switched routing with a synchronous multi-port switch design, fixed **XY routing** kinematics, and a **Round-Robin arbiter** with dynamic credit-based flow management to prevent congestion and internal deadlocks.

---

## 🚀 Key Architectural Features

* **5x5 Non-Blocking Crossbar Switch:** Provides parallel, non-blocking interconnects between 5 internal directions/ports: `West (0)`, `North (1)`, `East (2)`, `South (3)`, and `Local (4)`.
* **XY Routing Strategy:** Implements deterministic, distributed XY coordinate routing. Packets travel horizontally (along the X-axis) before shifting vertically (along the Y-axis), preventing routing loops.
* **Fair Round-Robin Arbitration:** Dynamic allocation architecture that prevents starvation by continuously shifting priorities among competing buffer ports requesting the same physical output channel.
* **Independent Input Queueing (FIFO):** Each communication port features an isolated, generic circular FIFO buffer to decouple data ingestion from internal switching speeds.
* **Credit-Based Backpressure/Flow Control:** Backpressure signaling (`credit_in` / `full` / `wr` handshakes) between adjacent network routers to ensure zero packet loss from memory overflows.

---

## 🏗️ Hardware Architecture & Component Hierarchy

The design decouples control path scheduling from data path switching. Below is the structural hierarchy mapping the provided source entities:
Router.vhd (Top-Level Node Container)
├── FIFO_Buffer.vhd (x5 - Dedicated input ring-buffers)
├── Routing_unit.vhd (x5 - Independent address-decoding logic)
├── Arbiter.vhd (x1 - Central Control Path Scheduler & Priority Handler)
└── Crossbar_switch.vhd (x1 - Core Data Path Multiplexer)

### Component Breakdown
1. **`Router.vhd`:** The top-level wrapper managing the synchronous clock/reset domains, stitching control signals, mapping port queues to the crossbar, and exposing neighbor inter-links.
2. **`Routing_unit.vhd`:** A purely combinational block parameterizable via `X_local` and `Y_local` generics. It extracts destination routing tags from packet headers and generates requested direction flags (`WEST`, `EAST`, `NORTH`, `SOUTH`, or `LOCAL`).
3. **`FIFO_Buffer.vhd`:** A dual-pointer behavioral circular queue parameterized by `DATA_WIDTH` and `ADDR_WIDTH` to handle data decoupling.
4. **`Arbiter.vhd`:** The core control brain. It evaluates requests across all 5 queues, verifies the availability of buffer tokens in adjacent routers (`credit_in`), resolves port collisions using round-robin token updating, and maps crossbar selectors.
5. **`Crossbar_switch.vhd`:** A high-speed, structural multiplexer array mapping incoming FIFO data lines directly onto outport boundaries based on Arbiter grants.

---

## 📟 Packet Frame Specification
The system works with configurable bitframes (defaulted to **12 bits** in testbenches), where the target physical coordinates are embedded natively in the leading header sequence:
┌─────────────────┬─────────────────┬──────────────────────────────────┐
│  Target X [3:2] │  Target Y [1:0] │       Payload Data [11:4]        │
└─────────────────┴─────────────────┴──────────────────────────────────┘

---

## 🛠️ Tech Stack & Simulation
* **Language:** VHDL-93 / VHDL-2008
* **Simulation Framework:** IEEE standard libraries (`std_logic_1164`, `numeric_std`)
* **Compatible Tools:** ModelSim, QuestaSim, GHDL, Xilinx Vivado, Intel Quartus Prime

---

## 🔬 Testbench & Verification Workflow

The project includes an advanced dual-node verification environment (**`tb_two_routers.vhd`**) to validate cascading inter-router handshakes and dynamic crossbar routing.

---
<img width="1920" height="1080" alt="3" src="https://github.com/user-attachments/assets/8b0e4d76-eb35-44c7-b281-ac6993f2d44d" />
<img width="1920" height="1080" alt="4" src="https://github.com/user-attachments/assets/c8477e90-e8c8-413c-9ec4-548e00e2397f" />
<img width="1920" height="1080" alt="5" src="https://github.com/user-attachments/assets/2d403460-215f-4c64-a0f4-acfd125389c9" />
<img width="1920" height="1080" alt="2" src="https://github.com/user-attachments/assets/de639725-f468-4a83-9695-a316cc40e034" />

