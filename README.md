# T-GEMM Core

A multiplierless 1.58-bit ternary systolic inference accelerator designed in synthesizable Verilog for sub-watt local edge intelligence.

![CI Status](https://img.shields.io/badge/verification-bit--exact%20pass-2ea043?style=flat-square)
![DSP Multipliers](https://img.shields.io/badge/DSP%20Multipliers-0-blue?style=flat-square)
![Process Target](https://img.shields.io/badge/Process-SkyWater%20130nm-orange?style=flat-square)

---

## Technical Summary
- **Arithmetic Architecture**: 0 DSP multipliers. Processing elements use 2-bit sign multiplexers paired with 3:2 Carry-Save Compressor adders (552 NAND2 gates per PE).
- **Weight Encoding**: Compressed Sparse Ternary (CST) decouples sparsity bitmaps from polarity vectors, hitting an empirical 1.50 bits/weight at 50% zero-sparsity.
- **Mesh Topology**: Reconfigurable systolic mesh operating in 2D systolic GEMM mode for prefill and dynamically folding into an 8-way parallel GEMV decode engine.
- **Physical Feasibility**: Floorplanned and gate-audited for SkyWater 130nm standard cell libraries (~0.12W estimated core power).

---

## Architectural Comparison: T-GEMM vs Standard INT8 MAC Array

| Metric | Standard INT8 Systolic Array | T-GEMM Ternary Core | Silicon Advantage |
| :--- | :--- | :--- | :--- |
| **Arithmetic Units** | Hard DSP Multipliers ($8\times8$ bit) | **Muxed 2's Complement Adders** | **100% Multiplierless** |
| **DSP Blocks Required** | 1 per Processing Element | **0 DSPs across entire mesh** | Eliminates DSP routing congestion |
| **Logic Gate Density** | ~650–800 NAND2 equivalents/PE | **~152–552 NAND2 equivalents/PE** | **~3× to 5× area reduction** |
| **Weight Storage Footprint** | 8 bits / parameter | **1.58 bits / parameter (CST format)** | **~5× memory bandwidth reduction** |
| **Dynamic Switching Energy** | High (switching multiplier trees) | Sub-watt (pure sign-inversion/bypass) | Ideal for battery-backed edge devices |

---

## Simulation Trace
Verified cycle-accurate RTL execution. Weight streams are shifted along vertical chains followed by skewed activation rows, producing bit-exact accumulated results without pipeline stalls:

![T-GEMM Waveform](docs/waveform.svg)

---

## Quickstart & Verification

### 1. Cycle-Accurate RTL Simulation
Run the automated testbench with zero dependencies other than Icarus Verilog:

```bash
make sim
