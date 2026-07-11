#!/bin/bash
# Exit immediately if any command fails
set -e

BASE_DIR="$HOME/stevia_md"
CONFIG_DIR="$BASE_DIR/config_files"
TRACKS=("matrix_BT_RebM" "matrix_BT_RebD" "matrix_Ecoli_RebM" "matrix_Ecoli_RebD")

for track in "${TRACKS[@]}"; do
    echo "=========================================================="
    echo " PROCESSING TRACK: $track"
    echo "=========================================================="
    cd "$BASE_DIR/$track"

    # 1. Dynamically identify the protein PDB file
    if [ -f "BT_GH3_clean.pdb" ]; then
        PDB_FILE="BT_GH3_clean.pdb"
    elif [ -f "ECOLI_GLUCOSIDASE.pdb" ]; then
        PDB_FILE="ECOLI_GLUCOSIDASE.pdb"
    else
        echo "Error: No PDB file found in $track" && exit 1
    fi

    # 2. Dynamically identify the ligand file prefix
    if [ -f "RebM.gro" ]; then
        LIG_PREFIX="RebM"
    elif [ -f "RebD.gro" ]; then
        LIG_PREFIX="RebD"
    else
        echo "Error: No ligand .gro file found in $track" && exit 1
    fi

    echo "Using Protein: $PDB_FILE"
    echo "Using Ligand:  $LIG_PREFIX"

    # 3. Process the raw protein structure flawlessly
    gmx pdb2gmx -f "$PDB_FILE" -o protein_processed.gro -p topol.top -ff amber99sb-ildn -water tip3p

    # 4. Set up a standardized dodecahedron box around the protein
    gmx editconf -f protein_processed.gro -o protein_box.gro -c -d 1.0 -bt dodecahedron

    # 5. Insert the ligand structurally into the box
    gmx insert-molecules -f protein_box.gro -ci "$LIG_PREFIX.gro" -nmol 1 -o complex_raw.gro

    # 6. Inject ligand topology files and molecule counts into topol.top
    # Add include line right after the forcefield include statement
    sed -i "/forcefield.itp\"/a #include \"$LIG_PREFIX.itp\"" topol.top
    # Append the true ligand name to the molecule registry at the bottom
    echo "UNL                1" >> topol.top

    # 7. Solvate the protein-ligand system
    gmx solvate -cp complex_raw.gro -cs spc216.gro -o complex_solv.gro -p topol.top

    # 8. Compile temporary TPR for ion calculation
    gmx grompp -f "$CONFIG_DIR/ions.mdp" -c complex_solv.gro -p topol.top -o ions.tpr -maxwarn 1

    # 9. Add neutralizing ions (Targeting 'SOL' group explicitly by name)
    echo "SOL" | gmx genion -s ions.tpr -o em_complex.gro -p topol.top -pname NA -nname CL -neutral

    # 10. Generate custom index mapping the explicit 'UNL' ligand group
    # Group 17 is created combining Protein (1) and residue UNL, then named Protein_UNL
    echo -e "1 | r UNL\nname 17 Protein_UNL\nq\n" | gmx make_ndx -f em_complex.gro -o index.ndx

    # 11. Compile final Energy Minimization file
    gmx grompp -f "$CONFIG_DIR/em.mdp" -c em_complex.gro -p topol.top -o em.tpr -maxwarn 1

    echo "Successfully generated em.tpr for $track!"
    echo "----------------------------------------------------------"
done

echo "ALL 4 TRACKS PREPARED PERFECTLY!"
