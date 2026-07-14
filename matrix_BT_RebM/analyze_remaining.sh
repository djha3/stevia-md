#!/bin/bash

# The remaining three folders to analyze
folders=("matrix_BT_RebD" "matrix_Ecoli_RebM" "matrix_Ecoli_RebD")

for folder in "${folders[@]}"; do
    echo "========================================================="
    echo " Processing: $folder"
    echo "========================================================="
    
    # Move into the folder
    cd "/home/darsh/stevia_md/$folder" || { echo "Directory $folder not found! Skipping..."; continue; }

    # 1. Automate RMSD
    # Pipes "4" (Backbone) for the fitting and "4" (Backbone) for the calculation
    echo -e "4\n4" | gmx rms -s md_20ns.tpr -f md_20ns.xtc -o rmsd_20ns.xvg

    # 2. Automate Minimum Distance
    # Pipes "1" (Protein) and "Other" (the default group name for the ligand)
    echo -e "1\nOther" | gmx mindist -s md_20ns.tpr -f md_20ns.xtc -od mindist_20ns.xvg

    # Return to the root folder
    cd /home/darsh/stevia_md
done

echo "========================================================="
echo "Done! All remaining .xvg data files have been generated."
echo "========================================================="
