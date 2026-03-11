# GC-eDRAM Behavioral Modeling with DRT Optimization

## Project Overview
This project focuses on the behavioral modeling and verification of a **Gain-Cell eDRAM (GC-eDRAM)**. Unlike traditional SRAM, eDRAM cells lose their charge over time, a phenomenon characterized by **Data Retention Time (DRT)**. 

The goal of this project is to create a simulation environment that models individual DRT values for each memory line. This allows for the development of adaptive refresh controllers that can significantly reduce power consumption by refreshing "strong" cells less frequently than "weak" ones.

## Key Features
- **Adaptive Decay Modeling**: Each memory line (512 lines, 64-bit wide) has a unique DRT value loaded from an external metadata file.
- **Cycle-Accurate Tracking**: Internal counters track the "age" of the data in each line. Once a line's counter exceeds its specific DRT, the data transitions to an 'X' (Unknown/Decayed) state.
- **Asynchronous Read/Synchronous Write**: Supports standard memory operations while maintaining the background decay process.
- **Automated Verification**: A SystemVerilog Testbench (`GC_DRAM_512_TB.v`) that monitors data integrity over a 2000ns period.

## Directory Structure
- `GC_DRAM_512/`: Contains the Verilog source code for the eDRAM model and the Testbench.
- `DRT_ARRAYS/`: Contains the metadata files (`drt_times.mem`) that define the retention characteristics of the memory.
- `waves.shm/`: Simulation waveform database (viewable in SimVision).

## Getting Started

### Prerequisites
- Cadence Xcelium (xrun)
- SimVision (for waveform analysis)

### Running the Simulation
To compile and run the simulation, navigate to the project directory and execute:
```bash
xrun GC_DRAM_512/GC_DRAM_512.v GC_DRAM_512/GC_DRAM_512_TB.v +access+rwc
