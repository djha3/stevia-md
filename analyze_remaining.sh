#!/bin/bash

folders=("matrix_BT_RebD" "matrix_Ecoli_RebM" "matrix_Ecoli_RebD")

for folder in "${folders[@]}"; do
    echo "========================================================="
    echo " Starting processing for: $folder"
    echo "========================================================="
    
    cd "/home/darsh/stevia_md/$folder" || { echo "❌ Directory $folder not found!"; continue; }

    echo "⏳ Crunching Backbone RMSD (this takes a minute)..."
    echo -e "4\n4" | gmx rms -s md_20ns.tpr -f md_20ns.xtc -o rmsd_20ns.xvg > /dev/null 2>&1
    echo "✅ RMSD complete for $folder!"

    echo "⏳ Crunching Minimum Distance..."
    echo -e "1\nOther" | gmx mindist -s md_20ns.tpr -f md_20ns.xtc -od mindist_20ns.xvg > /dev/null 2>&1
    echo "✅ Minimum Distance complete for $folder!"

    cd /home/darsh/stevia_md
done

echo "========================================================="
echo "🎉 All Done! Run your python3 plot_20ns.py script now!"
echo "========================================================="
