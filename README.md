# Smart GC-eDRAM Architecture with Dynamic LUT-SRAM Optimization

[cite_start]**Project:** DRT Optimization for GC-eDRAM Memory [cite: 1]  
[cite_start]**Authors:** Eyal Schiff, Yaniv Terner [cite: 3]  
[cite_start]**Supervisor:** Roman Golman (Prof. Adam Teman's Research Group) [cite: 4]  

## 📌 Project Overview
[cite_start]In modern System-on-Chip (SoC) architectures, embedded memories often become the primary bottleneck, allocating over 70% of their silicon real estate[cite: 8, 9]. [cite_start]Dynamic cells, such as Gain-Cell eDRAM (GC-eDRAM), offer high density but suffer from inherent volatility due to leakage currents (Sub-threshold, Gate, and Junction leakage)[cite: 37, 71].

[cite_start]The primary challenge is the "Refresh Penalty"[cite: 56]. [cite_start]Due to process variations, a small percentage of "Tail Cells" exhibit extremely short Data Retention Times (DRT), dictating a high refresh frequency for the entire array (e.g., a worst-case DRT of 1.4µs)[cite: 80, 93, 96]. 

This project introduces a **Smart Memory Controller** to optimize power. [cite_start]By identifying the weakest 512 cells in a 4096-line GC-eDRAM array and dynamically routing their data to a static SRAM via a Fully-Associative Look-Up Table (LUT), the system allows the main eDRAM array to operate at a significantly slower and more power-efficient refresh rate[cite: 496, 497, 499].

---

## 🏗️ System Architecture

[cite_start]The project is designed using a hierarchical SystemVerilog approach, expanding from a 512-line model to an 8-block large-scale memory[cite: 491, 492]:

1. [cite_start]**`OPT_GC_DRAM_4096` (Top-Level Controller):** The smart wrapper that manages data routing, multiplexing, and adaptive power logic[cite: 504, 505].
2. [cite_start]**`gc_edram_macro_4096`:** A structural 4096-line eDRAM array divided into 8 interleaved banks of 512 lines each[cite: 492].
3. [cite_start]**`gc_lut_512`:** A pure-combinational LUT storing the 512 worst-case DRT addresses[cite: 496].
4. [cite_start]**`gc_sram_512`:** A standard 512x64 static RAM block acting as stable, non-volatile storage for the metadata and payload of the weak addresses[cite: 498, 499].

---

## ⚙️ How the Smart Controller Works (Operational Logic)

[cite_start]To bridge the gap between physical circuit constraints and architectural-level design, we use a behavioral Verilog model that emulates DRT as a time-based decay process using dedicated decay counters[cite: 100, 101, 236].

### 1. The Write Operation (Parallel Execution)
[cite_start]During a write operation, the decay counter is reset to 0, representing the full recharging of the Storage Node[cite: 241]. 
* The target address is checked by the **LUT**. If flagged as "Bad" (`hit = 1`), the data is written to the SRAM. 
* To prevent critical-path delays, data is written simultaneously to both the SRAM and the GC-eDRAM.

### 2. The Read Operation (Multiplexed Routing)
[cite_start]The read path is modeled as a combinational process[cite: 244].
* **If MISS (`hit = 0`):** The address is healthy. The controller reads the data directly from the GC-eDRAM array.
* [cite_start]**If HIT (`hit = 1`):** The address is known to have a poor DRT (its eDRAM data has likely decayed to '1bx')[cite: 238]. The controller seamlessly toggles an output multiplexer to fetch the intact data from the SRAM instead.

### 3. Power Optimization
[cite_start]By bypassing unnecessary refresh cycles for the "strong" cells, the system achieves significant energy savings[cite: 497]. The controller disables the write/read enables to the main eDRAM array when a LUT HIT occurs, preventing the large array from switching unnecessarily.

---

## 🧪 Verification & Testing Environment

Robust verification ensures the complex routing and memory decaying logic work flawlessly.

* [cite_start]**Statistical Initialization:** An integer array `drt_values` is initialized from an external file (`drt_times.mem`), assigning a unique, statistical DRT to every cell, mimicking Monte Carlo simulation variations[cite: 233, 234, 235].
* **Hierarchical Data Injection:** The Top-Level module efficiently distributes the 4096 DRT values into the 8 interleaved 512-line banks.
* [cite_start]**Continuous Volatility Monitoring:** The testbench executes a "Write-Wait-Read" sequence with a strategic delay (e.g., `#2000` time units) to deliberately exceed the retention limit and verify that the model correctly transitions the data to an 'X' state[cite: 259, 263, 425].
* [cite_start]**SimVision Waveforms:** Provide definitive proof of the real-time response and data decay behavior, showing the exact moment the DRT threshold is crossed[cite: 429, 477].

## 🚀 How to Run the Simulation
1. Generate the statistical DRT files (Python):
   ```bash
   python3 DRT_ARRAYS/gen_drt.py
