import numpy as np

# Define dimensions
N = 4

# Generate random INT8 activations and {-1, 0, 1} ternary weights
np.random.seed(42)
A = np.random.randint(-128, 127, size=(N, N), dtype=np.int8)
W = np.random.choice([-1, 0, 1], size=(N, N))

# Compute golden matrix multiplication
Y_golden = np.matmul(A.astype(np.int32), W.astype(np.int32))

# Export hex files for Verilog $readmemh
def to_hex(arr, fname):
    with open(fname, "w") as f:
        for val in arr.flatten():
            f.write(f"{int(val) & 0xFF:02x}\n")

to_hex(A, "sim/activations.hex")
np.savetxt("sim/golden_outputs.txt", Y_golden, fmt="%d")
print("Golden vectors generated successfully.")
