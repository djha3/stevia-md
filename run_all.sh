#!/bin/bash
set -e

FOLDERS=("matrix_Ecoli_RebM" "matrix_Ecoli_RebD" "matrix_BT_RebM" "matrix_BT_RebD")

echo "===================================================="
echo " Starting GROMACS Pipeline (0 to 100 ns)"
echo "===================================================="

for FOLDER in "${FOLDERS[@]}"; do
    if [ -d "$FOLDER" ]; then
        echo ""
        echo "📂 Processing: $FOLDER"
        cd "$FOLDER"
        
        # 1. Compile the input files into a binary .tpr file
        echo "   -> Running grompp..."
        gmx grompp -f md.mdp -c complex_solv.gro -p topol.top -o md_100ns.tpr
        
        # 2. Run the simulation
        echo "   -> Running mdrun (this will take ~20 hours)..."
        gmx mdrun -v -deffnm md_100ns
        
        echo "✅ Finished $FOLDER!"
        cd ..
    else
        echo "⚠️ Directory $FOLDER not found."
    fi
done