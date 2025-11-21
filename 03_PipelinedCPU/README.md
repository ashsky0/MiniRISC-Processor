# ✅ **03_PipelinedCPU/README.md**

---

# Stage 3 — 5-Stage Pipelined RISC CPU

This stage implements a fully pipelined RISC CPU using the classic 5-stage architecture:

1. IF — Instruction Fetch  
2. ID — Instruction Decode  
3. EX — Execute  
4. MEM — Memory Access  
5. WB — Write Back

---

## 🧩 Features

- Pipeline registers between all stages
- **Forwarding Unit** to resolve data hazards
- **Hazard Detection Unit** to introduce stalls when required
- Flushing logic for taken branches
- Stall logic for load-use hazards
- Modular, readable pipeline design
- Reuses ALU and Register File from previous stages

---

## 📁 Directory Structure

```markdown
02_SingleCycleCPU/
├── docs/ # Final Report with schematics, design considerations, and results
├── src/ # Pipeline stage modules, control logic, forwarding, hazards
└── tb/ # Pipelined CPU system testbench
```

---

## 🧪 Simulation

To simulate:

```tcl
vlib work
vlog ../01_ALU/src/*.sv     ;# shared modules
vlog src/*.sv
vlog tb/testbench.sv
vsim testbench
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
- memfile3.dat
- TestingFile.dat

**memfile3.dat:**
```
MAIN   SUB  R0 R15 R15
       ADD  R1 R0 #1
       ORR  R2 R0 R1
       ADD  R2 R0 #2
       SUBS R0 R2 #0
       BEQ  TAG1
       AND  R2 R2 R0
       AND  R1 R2 R0
TAG1   ADD  R9 R1 R0
       STR  R9 [R0, #9]
       LDR  R3 [R0, #9]
       AND  R2 R3 R2
```

**TestingFile:** (consists of 5 tests)
- FIRST TEST FOR PIPELINE REGISTERS !
  - Only adds values that do not cause hazards
- SECOND TEST FOR PIPELINE REGISTERS !
  - Tests Forwarding
  - Only adds two values together that would cause a data hazard
- THIRD TEST FOR PIPELINE REGISTERS !
  - Tests stalling
  - Uses multiple operations to properly test
- FOURTH TEST FOR PIPELINE REGISTERS !
  - Tests branching and flag conditions
  - Uses SUBS (CMP) to store flags and BXX to branch
- FIFTH TEST FOR PIPELINE REGISTERS !
  - Tests all functions in one test
  - Adds more instructions to the memfile3 provided

---

## 📘 Notes

- ModelSim waveform and output screenshots are included in the project report for this stage.
You can reference that report from this directory.
- The tests within the TestingFile must be uncommented one at a time to ensure that the system
does not become confused between the tests. Please ensure that only one is uncommented at a time.


