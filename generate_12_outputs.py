import os
import matplotlib.pyplot as plt
import numpy as np

# Styling parameters
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['font.sans-serif'] = ['Arial', 'Liberation Sans', 'DejaVu Sans', 'sans-serif']
plt.rcParams['axes.edgecolor'] = '#333333'
plt.rcParams['axes.linewidth'] = 0.8

systems = {
    "matrix_BT_RebM": {"title": "B. theta (BT) + Reb M", "color": "#1f77b4"},
    "matrix_BT_RebD": {"title": "B. theta (BT) + Reb D", "color": "#17becf"},
    "matrix_Ecoli_RebM": {"title": "E. coli + Reb M", "color": "#2ca02c"},
    "matrix_Ecoli_RebD": {"title": "E. coli + Reb D", "color": "#ff7f0e"}
}

def parse_xvg(filepath, convert_to_ns=False):
    """Safely parses GROMACS .xvg files, ignoring header metadata."""
    x_val, y_val = [], []
    if not os.path.exists(filepath):
        return None, None
    with open(filepath, 'r') as f:
        for line in f:
            if line.startswith(('@', '#')):
                continue
            parts = line.split()
            if len(parts) >= 2:
                try:
                    x = float(parts[0])
                    if convert_to_ns:
                        x = x / 1000.0  # Convert picoseconds to nanoseconds
                    x_val.append(x)
                    y_val.append(float(parts[1]))
                except ValueError:
                    continue
    return np.array(x_val), np.array(y_val)

print("=========================================================")
print("🚀 RUNNING LOCAL INDIVIDUAL GRAPH & CSV BATCH GENERATOR")
print("=========================================================")

for folder, info in systems.items():
    print(f"\n📂 Reading directory: {folder}")
    
    # Files paths
    rmsd_path = f"{folder}/rmsd_20ns.xvg"
    dist_path = f"{folder}/mindist_20ns.xvg"
    rmsf_path = f"{folder}/rmsf_20ns.xvg"
    
    # -----------------------------------------------------------------
    # 1. PROCESS RMSD
    # -----------------------------------------------------------------
    t_rmsd, rmsd = parse_xvg(rmsd_path, convert_to_ns=True)
    if t_rmsd is not None:
        # Save CSV Table (Time in ns, RMSD in nm)
        csv_name = f"{folder}_rmsd.csv"
        with open(csv_name, 'w') as f:
            f.write("Time (ns),Backbone RMSD (nm)\n")
            for i in range(len(t_rmsd)):
                f.write(f"{t_rmsd[i]:.3f},{rmsd[i]:.3f}\n")
        print(f"   ↳ Created Table: {csv_name}")
        
        # Save Graph Plot
        plt.figure(figsize=(7, 4.5))
        plt.plot(t_rmsd, rmsd, color=info['color'], linewidth=1.5, label=info['title'])
        plt.title(f"Protein Backbone RMSD\nSystem: {info['title']}", fontsize=11, fontweight='bold', pad=10)
        plt.xlabel("Time (ns)", fontsize=10)
        plt.ylabel("RMSD (nm)", fontsize=10)
        plt.xlim(0, 20)
        plt.grid(True, linestyle='--', alpha=0.5)
        plt.legend(loc="lower right")
        plt.tight_layout()
        plot_name = f"{folder}_rmsd.png"
        plt.savefig(plot_name, dpi=300, bbox_inches='tight')
        plt.close()
        print(f"   ↳ Created Graph: {plot_name}")
    else:
        print(f"   ⚠️ Missing RMSD file: {rmsd_path}")

    # -----------------------------------------------------------------
    # 2. PROCESS MINIMUM DISTANCE
    # -----------------------------------------------------------------
    t_dist, dist = parse_xvg(dist_path, convert_to_ns=True)
    if t_dist is not None:
        # Save CSV Table (Time in ns, Min Distance in nm)
        csv_name = f"{folder}_mindist.csv"
        with open(csv_name, 'w') as f:
            f.write("Time (ns),Minimum Distance (nm)\n")
            for i in range(len(t_dist)):
                f.write(f"{t_dist[i]:.3f},{dist[i]:.3f}\n")
        print(f"   ↳ Created Table: {csv_name}")
        
        # Save Graph Plot
        plt.figure(figsize=(7, 4.5))
        plt.plot(t_dist, dist, color=info['color'], linewidth=1.5, label=info['title'])
        plt.title(f"Enzyme-Sweetener Minimum Distance\nSystem: {info['title']}", fontsize=11, fontweight='bold', pad=10)
        plt.xlabel("Time (ns)", fontsize=10)
        plt.ylabel("Minimum Distance (nm)", fontsize=10)
        plt.xlim(0, 20)
        plt.grid(True, linestyle='--', alpha=0.5)
        plt.legend(loc="upper right")
        plt.tight_layout()
        plot_name = f"{folder}_mindist.png"
        plt.savefig(plot_name, dpi=300, bbox_inches='tight')
        plt.close()
        print(f"   ↳ Created Graph: {plot_name}")
    else:
        print(f"   ⚠️ Missing Minimum Distance file: {dist_path}")

    # -----------------------------------------------------------------
    # 3. PROCESS RMSF
    # -----------------------------------------------------------------
    res_no, rmsf = parse_xvg(rmsf_path, convert_to_ns=False)
    if res_no is not None:
        # Save CSV Table (Residue Number, RMSF in nm)
        csv_name = f"{folder}_rmsf.csv"
        with open(csv_name, 'w') as f:
            f.write("Residue,Backbone RMSF (nm)\n")
            for i in range(len(res_no)):
                f.write(f"{int(res_no[i])},{rmsf[i]:.3f}\n")
        print(f"   ↳ Created Table: {csv_name}")
        
        # Save Graph Plot
        plt.figure(figsize=(7, 4.5))
        plt.plot(res_no, rmsf, color=info['color'], linewidth=1.2, label=info['title'])
        plt.title(f"Protein Backbone RMSF\nSystem: {info['title']}", fontsize=11, fontweight='bold', pad=10)
        plt.xlabel("Residue Number", fontsize=10)
        plt.ylabel("RMSF (nm)", fontsize=10)
        plt.xlim(res_no[0], res_no[-1])
        plt.grid(True, linestyle='--', alpha=0.5)
        plt.legend(loc="upper right")
        plt.tight_layout()
        plot_name = f"{folder}_rmsf.png"
        plt.savefig(plot_name, dpi=300, bbox_inches='tight')
        plt.close()
        print(f"   ↳ Created Graph: {plot_name}")
    else:
        print(f"   ⚠️ Missing RMSF file: {rmsf_path}")

print("\n=========================================================")
print("🎉 SUCCESS! All 12 graphs and 12 tables generated.")
print("=========================================================")

