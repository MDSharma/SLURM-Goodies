#!/bin/bash


##############################
# Build CoreMark-Pro
##############################
# git config --global http.proxy https://vmhpcproxy01.ex.ac.uk:3128
# git config --global https.proxy https://vmhpcproxy01.ex.ac.uk:3128
# git config --get-regexp https?.proxy
# git clone https://github.com/eembc/coremark-pro.git
# cd coremark-pro/
# make TARGET=linux64 build
##############################

# coremarkdir=$PWD/coremark-pro

# Get the list of queues
queues=$(sinfo -o "%P" | tail -n +2)

for queue in $queues
do
# Create a queue specific directory for benchmark
git config --global http.proxy https://vmhpcproxy01.ex.ac.uk:3128
git config --global https.proxy https://vmhpcproxy01.ex.ac.uk:3128
git clone https://github.com/eembc/coremark-pro.git ./coremark_test_$queue/


# Create a sbatch file for each queue
cat <<EOF > job_hpc_benchmark_$queue.sh
#!/bin/bash
#SBATCH -p $queue
#SBATCH --job-name=benchmark
#SBATCH --output=$queue_benchmark_%x_%j.out
#SBATCH -N 1
#SBATCH --exclusive


# Load necessary modules (modify as needed)
module load CUDAcore/11.1.1 OpenMPI/1.10.3-GCC-5.4.0-2.26

# Get the node type
NODE_NAME=\$(hostname)

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
echo '------------------'

########################
# Run CoreMark benchmark
########################

echo 'Running CoreMark on '\${NODE_NAME}' in $queue'

# Get the number of cores
num_cores=\$(nproc --all)

# Print the number of cores
echo 'The number of cores is: '\${num_cores}


WLD_CMD_FLAGS=i10000;
cd coremark_test_$queue;
pwd;
echo "running make TARGET=linux64 XCMD=-c"\${num_cores} " certify-all > coremark_"\${NODE_NAME}"_${queue}.out"
make TARGET=linux64 XCMD=-c\${num_cores} certify-all > ../coremark_\${NODE_NAME}_${queue}.out
echo "all done, cleaning up"
cd ../
rm -rf coremark_test_$queue
echo "sorted"

####################
# Run GPU Benchmark
####################
# Get GPU info
if command -v nvidia-smi &> /dev/null
then
    echo 'GPU Info:'
    nvidia-smi
# and run the benchmark here

else
    echo 'No GPU info available'
fi
echo '------------------'


####################
# Run HPL Benchmark
####################


EOF

    # Make the sbatch file executable
    chmod +x job_coremark_$queue.sh
done

