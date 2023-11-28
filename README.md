# SLURM-Goodies

### Find and kill my pending jobs:
This script looks up who the executing user is and then generates a list of all pending jobs for that uid in Slurm. It then goes ahead and cancels those jobs.

### find_slurm_queues_and_specs.sh 
This script will use sinfo to query a list of all the queues on your HPC system (Slurm) and then create a set of sbatch (job) files that can be used to gather CPU; Hyperthreading; RAM; GPU and Infiniband info details from each of your queues. Most well configured systems would already allow you to see such a summary via ``` sinfo -Nel ```. However, when it's not the case.. you can use this script as it is, or modify it further to suit your needs.

