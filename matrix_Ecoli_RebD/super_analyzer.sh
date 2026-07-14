#!/bin/bash

ROOT_DIR="/home/darsh/stevia_md"
folders=("matrix_BT_RebM" "matrix_BT_RebD" "matrix_Ecoli_RebM" "matrix_Ecoli_RebD")

echo "========================================================="
echo "🚀 STARTING AUTOMATED GROMACS RECOVERY & ANALYSIS"
echo "========================================================="

for folder in "${folders[@]}"; do
    echo ""
    echo "📁 Current Folder: $folder"
    echo "--------------------------------------------------------"
    
    # 1. Navigate to directory
    cd "$ROOT_DIR/$folder" || { echo "❌ Error: Cannot enter directory $folder. Skipping..."; continue; }
    
    # 2. Track down or compile the .tpr file automatically
    TPR_FILE="md_20ns.tpr"
    if [ ! -f "$TPR_FILE" ]; then
        if [ -f "md.tpr" ]; then
            TPR_FILE="md.tpr"
            echo "ℹ️  Found alternative file: 'md.tpr'."
        elif [ -f "topol.tpr" ]; then
            TPR_FILE="topol.tpr"
            echo "ℹ️  Found alternative file: 'topol.tpr'."
        else
            echo "🛠️  Missing .tpr file! Attempting to compile a fresh one automatically..."
            if [ -f "md.mdp" ] && [ -f "npt.gro" ] && [ -f "npt.cpt" ] && [ -f "topol.top" ]; then
                gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o md_20ns.tpr > grompp_build.log 2>&1
                if [ -f "md_20ns.tpr" ]; then
                    TPR_FILE="md_20ns.tpr"
                    echo "✅ Successfully built a fresh md_20ns.tpr file!"
                else
                    echo "❌ Failed to compile .tpr file automatically. Error details below:"
                    tail -n 6 grompp_build.log
                    continue
                fi
            else
                echo "❌ Cannot compile .tpr file because setup files (md.mdp, npt.gro, etc.) are missing. Skipping folder."
                continue
            fi
        fi
    fi

    # 3. Handle Trajectory File Naming
    XTC_FILE="md_20ns.xtc"
    if [ ! -f "$XTC_FILE" ]; then
        if [ -f "md.xtc" ]; then
            XTC_FILE="md.xtc"
        else
            echo "❌ Error: Could not find any trajectory file (md_20ns.xtc or md.xtc) in this folder. Skipping..."
            continue
        fi
    fi

    # 4. Process Backbone RMSD
    echo "⏳ Crunching Backbone RMSD (Analyzing 2.1 GB dataset)..."
    echo -e "4\n4" | gmx rms -s "$TPR_FILE" -f "$XTC_FILE" -o rmsd_20ns.xvg > rmsd_run.log 2>&1
    
    if [ -f "rmsd_20ns.xvg" ]; then
        echo "✅ Backbone RMSD successfully generated!"
    else
        # Try fallback using group name text strings instead of numbers
        echo -e "Backbone\nBackbone" | gmx rms -s "$TPR_FILE" -f "$XTC_FILE" -o rmsd_20ns.xvg >> rmsd_run.log 2>&1
        if [ -f "rmsd_20ns.xvg" ]; then
            echo "✅ Backbone RMSD successfully generated (via fallback text tags)!"
        else
            echo "❌ RMSD calculation failed. GROMACS error dump below:"
            tail -n 8 rmsd_run.log
        fi
    fi

    # 5. Process Minimum Distance
    echo "⏳ Crunching Minimum Distance between Enzyme and Sweetener..."
    # Try the standard GROMACS group name "Other" first
    echo -e "Protein\nOther" | gmx mindist -s "$TPR_FILE" -f "$XTC_FILE" -od mindist_20ns.xvg > mindist_run.log 2>&1
    
    if [ -f "mindist_20ns.xvg" ]; then
        echo "✅ Minimum Distance successfully generated!"
    else
        # Fallback to alternative group name "UNK" if "Other" is not recognized
        echo -e "Protein\nUNK" | gmx mindist -s "$TPR_FILE" -f "$XTC_FILE" -od mindist_20ns.xvg >> mindist_run.log 2>&1
        if [ -f "mindist_20ns.xvg" ]; then
            echo "✅ Minimum Distance successfully generated (via UNK molecule mapping)!"
        else
            echo "❌ Minimum Distance calculation failed. GROMACS error dump below:"
            tail -n 8 mindist_run.log
        fi
    fi
done

echo ""
echo "========================================================="
echo "🎉 ALL FOLDERS EVALUATED! READY FOR PLOTTING!"
echo "========================================================="
