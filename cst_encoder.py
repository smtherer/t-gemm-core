import numpy as np

def encode_cst_tile(tile_weights):
    flat = tile_weights.flatten()
    mask_64 = 0
    sign_stream = 0
    nz_count = 0
    for idx, val in enumerate(flat):
        if val != 0:
            mask_64 |= (1 << idx)
            if val == -1:
                sign_stream |= (1 << nz_count)
            nz_count += 1
    return mask_64, sign_stream, nz_count, 64 + nz_count

def decode_cst_tile(mask_64, sign_stream):
    flat = np.zeros(64, dtype=np.int8)
    nz_ptr = 0
    for idx in range(64):
        if (mask_64 >> idx) & 1:
            sign_bit = (sign_stream >> nz_ptr) & 1
            flat[idx] = -1 if sign_bit == 1 else 1
            nz_ptr += 1
        else:
            flat[idx] = 0
    return flat.reshape((8, 8))
