# T-GEMM Core

A multiplierless 1.58-bit ternary systolic inference accelerator designed in synthesizable Verilog for sub-watt local edge intelligence.

## Technical Summary
- **Arithmetic Architecture**: 0 DSP multipliers. Processing elements use 2-bit sign multiplexers paired with 3:2 Carry-Save Compressor adders (552 NAND2 gates per PE).
- **Weight Encoding**: Compressed Sparse Ternary (CST) decouples sparsity bitmaps from polarity vectors, hitting an empirical 1.50 bits/weight at 50% zero-sparsity.
- **Mesh Topology**: Reconfigurable 8x8 systolic mesh operating in 2D systolic GEMM mode for prefill and dynamically folding into an 8-way parallel GEMV decode engine.
- **Physical Feasibility**: Floorplanned and gate-audited for SkyWater 130nm standard cell libraries (~0.12W estimated core power).

## Repository Structure
```text
├── rtl/
│   ├── csa_accumulator.v        # 3:2 carry-save adder tree
│   ├── cst_decoder.v            # In-flight zero-stall stream unpacker
│   ├── systolic_gemm_engine.v   # Dual-mode mesh controller
│   ├── ternary_pe.v             # Multiplierless processing element
│   ├── ternary_pe_gated.v       # Zero-skipping clock-gated PE variant
│   └── ternary_systolic_8x8.v   # Top-level compute fabric
├── benchmark_8x8_layer.py       # Cycle-accurate latency measurement
├── benchmark_cst.py             # Compression ratio verification on SmolLM-135M
├── cst_encoder.py               # Sparse ternary matrix packing utility
├── gate_level_audit.py          # Netlist gate count & area verification
├── test_advanced_features.py    # Zero-skipping clock gating test harness
└── verify_all.py                # Master bit-exact validation against PyTorch
```

## Hardware Verification
The test harness runs cycle-accurate register-transfer level simulation directly against PyTorch reference tensors to verify bit-exact outputs with 0.00 MSE:

```bash
python3 verify_all.py
```

### Netlist Audit
To audit equivalent NAND2 gate counts, confirm 0 hardware multipliers, and calculate physical die estimates across process nodes:

```bash
python3 gate_level_audit.py
```

## Tapeout Status
- **RTL**: Complete and verified
- **Synthesis**: Gate-level netlist clean
- **Next Milestone**: FPGA prototype validation (AMD Zynq-7020) and physical tapeout via Tiny Tapeout (SkyWater 130nm)
