#!/bin/bash

set -e
TARGET_TIME=100000 # 100 ns
FOLDERS=("matrix_Ecoli_RebM" "matrix_Ecoli_RebD" "matrix_BT_RebM" "matrix_BT_RebD")

echo "===================================================="
echo " Starting GROMACS Automation inside WSL"
echo "===================================================="

for FOLDER in "${FOLDERS[@]}"; do
    if [ -d "$FOLDER" ]; then
        echo ""
        echo "📂 Entering: $FOLDER"
        cd "$FOLDER"
        
        # Identify the TPR file (allowing for no extension)
        TPR_FILE=""
        if [ -f "md_20ns.tpr" ]; then TPR_FILE="md_20ns.tpr"; elif [ -f "md_20ns" ]; then TPR_FILE="md_20ns"; fi
        
        # Identify the CPT file (allowing for state.cpt or md_20ns.cpt)
        CPT_FILE=""
        if [ -f "md_20ns.cpt" ]; then CPT_FILE="md_20ns.cpt"; elif [ -f "state.cpt" ]; then CPT_FILE="state.cpt"; fi
        
        if [ -z "$TPR_FILE" ] || [ -z "$CPT_FILE" ]; then
            echo "❌ Missing .tpr or .cpt in $FOLDER. Skipping."
            cd ..
            continue
        fi
        
        echo "   -> Extending TPR..."
        gmx convert-tpr -s "$TPR_FILE" -until "$TARGET_TIME" -o md_100ns.tpr
        
        echo "   -> Running mdrun..."
        gmx mdrun -v -s md_100ns.tpr -cpi "$CPT_FILE" -append
        
        echo "✅ Finished $FOLDER!"
        cd ..
    else
        echo "⚠️ Directory $FOLDER not found."
    fi
done


