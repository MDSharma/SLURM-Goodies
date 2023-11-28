#!/bin/bash

# Get the user's username
username=$(whoami)

# Get a list of all pending jobs for the user
jobs=$(squeue -u $username -t PENDING -h -o "%i")

# Cancel each job
for job in $jobs
do
  echo "Cancelling job $job"
  scancel $job
done

echo "All pending jobs cancelled."
