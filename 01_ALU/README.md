# ✅ **01_ALU/README.md**

---

# Stage 1 — Arithmetic Logic Unit (ALU)

This stage implements the ALU used throughout all later MiniRISC CPU stages.  
It performs arithmetic, logic, shifting, and comparison operations, and outputs flags used for branching.

---

## 🧩 Features

- 32-bit arithmetic operations (ADD, SUB)
- Logical operations (AND, OR, XOR)
- Shift left / shift right
- Set-less-than comparison
- Zero and overflow flag generation
- Clean, parameterized SystemVerilog implementation
- Fully testbench-verified

---

## 📁 Directory Structure

```markdown
01_ALU/
├── docs/ # Final Report with schematics, design considerations, and results
├── sim/ # ModelSim Results (can also be found in report)
├── src/ # ALU SystemVerilog design
└── tb/ # ALU unit testbench + simulation files
```

---

## 🧪 Simulation

To run the ALU testbench in ModelSim:

```tcl
vlib work
vlog src/*.sv
vlog tb/alu_testbench.sv
vsim alu_testbench
run -all
```

Expected outputs:
- Correct arithmetic/logic behavior for all operations
- Valid zero flag detection
- Valid overflow detection
- Shift operations behave according to spec

Test Vectors Used:

<img width="339" height="543" alt="Screenshot 2025-11-21 at 1 28 04 PM" src="https://github.com/user-attachments/assets/0598ece4-da2f-449a-b3a1-940d1b5bbf3b" />

---

## 📘 Notes

This ALU is reused in Stage 2 and Stage 3 without modification.
Later CPU stages test the ALU indirectly through CPU-level test programs.
