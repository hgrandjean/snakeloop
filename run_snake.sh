#!/bin/bash
#SBATCH -o %x.%N.%j.out
#SBATCH -e %x.%N.%j.err
#SBATCH --cpus-per-task=1
#SBATCH -J snakeloop

# Run snakemake with cluster configuration
snakemake --jobs 24 \
  --cluster "sbatch \
    --parsable \
    --job-name={rule}.{wildcards} \
    --output=logs/{rule}.{wildcards}.%j.out \
    --error=logs/{rule}.{wildcards}.%j.err \
    --cpus-per-task={threads}" \
  --latency-wait 60 \
  --rerun-incomplete

