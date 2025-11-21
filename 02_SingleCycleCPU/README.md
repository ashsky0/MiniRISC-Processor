# ✅ **02_SingleCycleCPU/README.md**

---

# Stage 2 — Single-Cycle RISC CPU

This stage builds on the ALU to create a full single-cycle RISC processor.  
Each instruction completes in one clock cycle, making the architecture simple and easy to verify.

---

## 🧩 Implemented Components

- **Program Counter**
- **Instruction Memory**
- **Register File**
- **Control Unit**
- **ALU + ALU Control**
- **Immediate Generator**
- **Data Memory**
- **Branch Comparator / Branch Logic**
- **Top-level CPU module**

---

## 📁 Directory Structure

```markdown
02_SingleCycleCPU/
├── docs/ # Final Report with schematics, design considerations, and results
├── sim/ # ModelSim Results (can also be found in report)
├── src/ # CPU modules for single-cycle architecture
└── tb/ # Single-cycle CPU testbench + support programs
```

---

## 🧪 Simulation

To simulate:

```tcl
vlib work
vlog ../01_ALU/src/*.sv        ;# ALU reuse
vlog src/*.sv
vlog tb/SingleCycleCPU_tb.sv
vsim SingleCycleCPU_tb
run -all
```
✔ What the Testbench Covers
- Instruction fetch/decode correctness
- ALU integration with CPU datapath
- Register file read/write operations
- Branch correctness
- Memory load/store functionality
- A simple test program demonstrating basic instruction flow

**Two Different Test Vectors Used** 
- memfile.dat
- memfile2.dat

**memfile.dat:**

<img width="633" height="465" alt="Screenshot 2025-11-21 at 1 43 05 PM" src="https://github.com/user-attachments/assets/191b3c5a-b543-410e-af5c-6d49e9cd17c8" />


**memfile2.dat:**

<img width="535" height="648" alt="Screenshot 2025-11-21 at 1 43 39 PM" src="https://github.com/user-attachments/assets/f46d5e5b-fef1-4cbd-bdb2-89f0a4baa00e" />

---

## 📘 Notes

The test vector files are instantiated in the imem.sv file. Please edit it to which file you would like to use. 
Reuses source files from 01_ALU.


