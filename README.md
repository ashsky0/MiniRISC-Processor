# MiniRISC Processor

![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)
![Made with: SystemVerilog](https://img.shields.io/badge/made%20with-SystemVerilog-orange)
![Simulator: ModelSim](https://img.shields.io/badge/simulator-ModelSim-green)

A multi-stage RISC processor implementation built in SystemVerilog, progressing from a standalone ALU to a fully pipelined CPU.  
This project demonstrates hardware design principles, incremental CPU development, and simulation-based verification.

---

## 📁 Repository Structure

```
/
│
├── 01_ALU/ # Arithmetic Logic Unit (Stage 1)
│ ├── docs/ # Technical Report
│ ├── sim/ # ModelSim Photos 
│ ├── src/ # Source Files
│ ├── tb/ # Testbench Files
│ └── README.md
│
├── 02_SingleCycleCPU/ # Single-Cycle RISC Processor (Stage 2)
│ ├── docs/
│ ├── sim/
│ ├── src/
│ ├── tb/
│ └── README.md
│
├── 03_PipelinedCPU/ # 5-Stage Pipelined RISC Processor (Stage 3)
│ ├── docs/ # Report contains ModelSim Photos
│ ├── src/
│ ├── tb/
│ └── README.md 
│
├── LICENSE 
└── README.md # (this file)
```

Each stage builds upon the previous, adding architectural complexity while reusing core modules within the 01_ALU folder.

---

## 🚀 Project Goals

- Build a simple RISC processor incrementally in three stages
- Learn SystemVerilog design practices and module reuse
- Develop testbenches for simulation-based verification
- Understand pipelining, hazard detection, and forwarding
- Maintain clean project structure and documentation

---

## 🔧 Tools Used

- **SystemVerilog**
- **ModelSim** for simulation
- **Quartus** for synthesising

---

## 📘 Stages Overview

### **1️⃣ Stage 1 — ALU**
Implements a standalone Arithmetic Logic Unit capable of add, subtract, logic operations, shifts, comparisons, and flag generation.
<img width="536" height="378" alt="Screenshot 2025-11-21 at 1 18 30 PM" src="https://github.com/user-attachments/assets/c48c96c4-597e-4b1c-b499-63133eeb1e26" />


### **2️⃣ Stage 2 — Single-Cycle CPU**
A complete RISC processor where each instruction executes in a single clock cycle. Includes:
- Instruction decode
- ALU integration
- Register file
- Control unit
- Data memory
- Branch logic
<img width="750" height="408" alt="Screenshot 2025-11-21 at 1 19 30 PM" src="https://github.com/user-attachments/assets/14eab9cd-eaf4-4be5-8401-1da2f9524ffd" />

### **3️⃣ Stage 3 — Pipelined CPU**
A 5-stage processor with:
- IF, ID, EX, MEM, WB pipeline stages
- Forwarding unit
- Hazard detection unit
- Stall logic and flushing
- Separated pipeline registers
<img width="736" height="384" alt="Screenshot 2025-11-21 at 1 20 19 PM" src="https://github.com/user-attachments/assets/2eac1295-67be-40af-b184-8145301adc0f" />

ModelSim output screenshots for this stage are included in the **project report**, referenced inside the `03_PipelinedCPU/docs` folder.

---

## ▶️ How to Run Simulations

Each stage contains:
- `src/` — SystemVerilog source files
- `tb/` — Testbenches

To simulate (example for ModelSim):

```tcl
vlib work
vlog src/*.sv ../01_ALU/src/*.sv
vlog tb/<testbench_name>.sv
vsim <top_tb>
run -all
```

---

## 👥 Authors

- **Ashley Guillard**  
- **Gene Mary Cheruvathur**

---

## 📄 License

This project is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for details.

---
