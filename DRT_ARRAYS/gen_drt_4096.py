import os
import random

# Settings
NUM_LINES = 4096
NUM_BAD = 512

# 1. Create DRT array for all cells (100-500 clock cycles)
drt_array = [random.randint(100, 500) for _ in range(NUM_LINES)]

# 2. Find the worst addresses (array of 512 addresses)
# Create a list of tuples (address, DRT) and sort by DRT
indexed_drt = list(enumerate(drt_array))
indexed_drt.sort(key=lambda x: x[1])

# 512 addresses with the lowest DRT
bad_addresses = [item[0] for item in indexed_drt[:NUM_BAD]]

# 3. Calculate the new minimum DRT (The 513th value in the sorted list)
# This is the DRT that determines the refresh rate of the GCDRAM after the fix
new_min_drt = indexed_drt[NUM_BAD][1]

# --- Verification Prints ---
print("--- Check Data ---")
# Printing all elements in the arrays as requested
print(f"All DRT values: {drt_array[:]}")
print(f"All 512 Bad Addresses: {bad_addresses[:512]}")
print(f"Total Bad Addresses stored: {len(bad_addresses)}")
print("-" * 20)
print(f"Worst DRT in system (before fix): {indexed_drt[0][1]}")
print(f"New Minimum DRT (after moving 512 cells to SRAM): {new_min_drt}")

# --- Save to files for Verilog ---
# Get the exact path where the Python script is currently located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Connect the path to the unique file names (adding _4096)
path_drt = os.path.join(script_dir, "drt_times_4096.mem")
path_bad = os.path.join(script_dir, "bad_addresses_4096.mem")

with open(path_drt, "w") as f:
    for val in drt_array: 
        f.write(f"{val:x}\n")

with open(path_bad, "w") as f:
    for addr in bad_addresses: 
        f.write(f"{addr:x}\n")

print(f"Success! Files saved at: {script_dir}")
print("Generated files: drt_times_4096.mem, bad_addresses_4096.mem")