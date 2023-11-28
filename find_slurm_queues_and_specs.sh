#!/bin/bash

# Get the list of queues
queues=$(sinfo -o "%P" | tail -n +2)

for queue in $queues
do
    # Create an sbatch file for each queue
    echo "#!/bin/bash
#SBATCH -p $queue
#SBATCH -N 1
#SBATCH --exclusive
#SBATCH --output=$queue_report_%x_%j.out


# Load necessary modules (modify as needed)
module load CUDAcore/11.1.1 OpenMPI/1.10.3-GCC-5.4.0-2.26

# Get CPU info
echo 'CPU Info:'
lscpu
echo '------------------'

# Check if hyperthreading is enabled
echo 'Hyperthreading:'
if lscpu | grep -q 'Thread(s) per core: *2'
then
    echo 'Enabled'
else
    echo 'Disabled'
fi
echo '------------------'

# Get RAM info
echo 'RAM Info:'
free -h
echo '------------------'

# Get GPU info
if command -v nvidia-smi &> /dev/null
then
    echo 'GPU Info:'
    nvidia-smi
else
    echo 'No GPU info available'
fi
echo '------------------'

# Get Infiniband speed
if command -v ibstat &> /dev/null
then
    echo 'Infiniband Card:'
    lspci | grep Mellanox
    echo 'Infiniband Speed:'
    ibstat | grep -e 'Rate\|Link layer'
else
    echo 'No Infiniband info available'
fi
echo '------------------'" > job_$queue.sh

    # Make the sbatch file executable
    chmod +x job_$queue.sh
done

