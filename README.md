# Evaluating the Eubiotic and Dysbiotic Potential of Rebaudioside M & D

This repository contains the in silico molecular dynamics (MD) simulation setups to evaluate how gut microbial enzymes (from *Bacteroides thetaiotaomicron* and *E. coli*) interact with steviol glycosides (Rebaudioside D and Rebaudioside M). 

## Repository Structure
* `/config_files`: Centralized master `.mdp` templates configured for a 20 ns production run.
* `/matrix_BT_RebD`: Simulation inputs for *B. thetaiotaomicron* enzyme + Rebaudioside D.
* `/matrix_BT_RebM`: Simulation inputs for *B. thetaiotaomicron* enzyme + Rebaudioside M.
* `/matrix_Ecoli_RebD`: Simulation inputs for *E. coli* enzyme + Rebaudioside D.
* `/matrix_Ecoli_RebM`: Simulation inputs for *E. coli* enzyme + Rebaudioside M.

## How to Run the Simulations
The 20 ns production pipeline is automated via `run_all_20ns.sh`. It sequentially compiles the `.tpr` files using `gmx grompp` and executes the trajectories using `gmx mdrun`.
