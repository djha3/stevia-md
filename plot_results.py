import os
import matplotlib.pyplot as plt

def parse_xvg(filepath):
    """Parses GROMACS .xvg files while skipping metadata header lines."""
    x, y = [], []
    with open(filepath, 'r') as f:
        for line in f:
            if line.startswith(('@', '#')):
                continue
            parts = line.split()
            if len(parts) >= 2:
                x.append(float(parts[0]))
                y.append(float(parts[1]))
    return x, y

tracks = ["matrix_BT_RebM", "matrix_BT_RebD", "matrix_Ecoli_RebM", "matrix_Ecoli_RebD"]
base_dir = os.path.expanduser("~/stevia_md")

# 1. Plot RMSD (Over Time)
plt.figure(figsize=(10, 5))
for track in tracks:
    path = os.path.join(base_dir, track, "rmsd.xvg")
    if os.path.exists(path):
        time, rmsd = parse_xvg(path)
        plt.plot(time, rmsd, label=track)
plt.title("Protein Backbone RMSD (Structural Stability)")
plt.xlabel("Time (ps)")
plt.ylabel("RMSD (nm)")
plt.legend()
plt.grid(True)
plt.savefig("all_tracks_rmsd.png")
plt.close()

# 2. Plot Minimum Distance (Over Time)
plt.figure(figsize=(10, 5))
for track in tracks:
    path = os.path.join(base_dir, track, "mindist.xvg")
    if os.path.exists(path):
        time, dist = parse_xvg(path)
        plt.plot(time, dist, label=track)
plt.title("Minimum Distance Between Enzyme and Sweetener")
plt.xlabel("Time (ps)")
plt.ylabel("Minimum Distance (nm)")
plt.legend()
plt.grid(True)
plt.savefig("all_tracks_hbonds.png")  # Kept the filename same so your viewing pipeline is unchanged
plt.close()

print("Graphs updated successfully with real spatial distances!")
