# GC-eDRAM Behavioral Modeling with DRT Optimization
*B.Sc. Electrical Engineering Final Project (Active Development)*

## Project Overview
This project focuses on the behavioral modeling and architectural optimization of **Gain-Cell eDRAM (GC-eDRAM)** arrays. Unlike traditional static memory (SRAM), eDRAM cells suffer from leakage and lose their charge over time, a phenomenon characterized by **Data Retention Time (DRT)**. 

The core essence of this project is to simulate this volatility digitally and exploit the statistical variations in DRT across different memory cells. By accurately emulating memory decay, we are building the foundation for a smart, adaptive refresh controller designed to significantly reduce standby power consumption by refreshing "strong" cells less frequently than "weak" ones.

## Key Features
- **Adaptive Decay Modeling:** Each memory line (512 lines, 64-bit wide) has a unique DRT value loaded from an external statistical metadata file.
- **Cycle-Accurate Tracking:** Internal digital counters track the "age" of the data in each line. Once a line's counter exceeds its specific DRT threshold, the data transitions to an 'X' (Unknown/Decayed) state.
- **Asynchronous Read / Synchronous Write:** Supports standard memory operations while maintaining the continuous background decay process.
- **Automated Verification:** A dedicated SystemVerilog Testbench (`GC_DRAM_512_TB.v`) that monitors data integrity and functional volatility in real-time.

## Future Architecture & Roadmap
To achieve the ultimate goal of granular power optimization, the system architecture will be expanded to include:
- **Large-Scale Hierarchical Integration:** Scaling the core memory into an 8-block architecture for independent block-level power management.
- **LUT-Based Adaptive Refresh:** Implementing a Look-Up Table (LUT) logic to track retention profiles, allowing the system to skip unnecessary refresh cycles for cells with high DRT.
- **SRAM Metadata Storage:** Developing a stable, behavioral SRAM macro to act as non-volatile storage for the LUT data and weak-cell pointers.
- **Smart Control & Multiplexing Logic:** Designing an intelligent controller to route data between the eDRAM blocks and the SRAM, triggering targeted refresh pulses only when strictly necessary, followed by a comprehensive system power analysis.

## Directory Structure
- `GC_DRAM_512/`: Contains the Verilog source code for the eDRAM behavioral model and the verification Testbench.
- `DRT_ARRAYS/`: Contains the metadata files (`drt_times.mem`) that define the retention characteristics and distribution of the memory.
- `waves.shm/`: Simulation waveform database (viewable via SimVision).

## Getting Started

### Prerequisites
- **Cadence Xcelium** (`xrun`) for simulation.
- **SimVision** for waveform analysis.

### Running the Simulation
To compile and run the simulation, navigate to the root project directory and execute:
```bash
xrun GC_DRAM_512/GC_DRAM_512.v GC_DRAM_512/GC_DRAM_512_TB.v +access+rwc
