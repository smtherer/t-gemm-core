# Toolchain flags
IVERILOG = iverilog -g2012
VVP      = vvp
YOSYS    = yosys
GTKWAVE  = gtkwave

# Source files
RTL_SRC  = rtl/t_pe.v rtl/t_gemm_top.v
TB_SRC   = sim/tb_t_gemm.v
SIM_BIN  = sim/sim.vvp

.PHONY: all sim wave synth clean

all: sim synth

# Run cycle-accurate verification
sim: $(SIM_BIN)
	$(VVP) $(SIM_BIN)

$(SIM_BIN): $(RTL_SRC) $(TB_SRC)
	$(IVERILOG) -o $(SIM_BIN) $(RTL_SRC) $(TB_SRC)

# View waveform trace
wave: sim
	$(GTKWAVE) waveform.vcd &

# Run gate-level synthesis & print cell metrics
synth:
	$(YOSYS) -p "read_verilog $(RTL_SRC); synth -top t_gemm_top; stat"

# Clean build artifacts
clean:
	rm -f sim/*.vvp waveform.vcd
