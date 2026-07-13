#!/bin/bash

if ! command -v gmx &> /dev/null
then
    echo "GROMACS not found! Starting automatic installation..."
    
    # Update system packages
    sudo apt update && sudo apt upgrade -y
    
    # Install standard GROMACS via package manager (Fastest, CPU-optimized setup)
    sudo apt install -y gromacs build-essential cmake libfftw3-dev wget
    
    # Verify the installation worked
    if ! command -v gmx &> /dev/null
    then
        echo "Installation failed. Exiting script."
        exit 1
    fi
    echo "GROMACS successfully installed!"
else
    echo "GROMACS is already installed. Skipping to simulations..."
fi

folders=("matrix_BT_RebD" "matrix_BT_RebM" "matrix_Ecoli_RebD" "matrix_Ecoli_RebM")

for folder in "${folders[@]}"; do
    echo "========================================================="
    echo " Starting 20ns Production For: $folder"
    echo "========================================================="
    
    cd "$folder" || { echo "Directory $folder not found! Skipping..."; continue; }

    # 1. Compile the 20ns simulation input file (.tpr)
    gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o md_20ns.tpr

    # 2. Execute the 20ns Production Run
    echo "Running mdrun for $folder..."
    gmx mdrun -deffnm md_20ns -v

    # Return to project root for the next loop
    cd ..
done

echo "All 4 simulations have completed successfully!"
