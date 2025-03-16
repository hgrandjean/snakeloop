import glob
import pandas as pd
import os
import shutil

# Configuration
SAMPLES_TSV = "samples.tsv"
GENOMAD_DB = "/Users/hugo/work/genomad_db"

# Load sample information
config_df = pd.read_csv(SAMPLES_TSV, sep="\t")
sample_dict = dict(zip(config_df["sample"], config_df["path"]))
SAMPLES = list(sample_dict.keys())

# Find name of fasta file based on sample name
def find_fna(wildcards):
    """Finds the .fna.gz file inside the sample folder."""
    sample_path = wildcards.sample_path  # Use directly from wildcards
    fasta_files = glob.glob(f"{sample_path}/*.fna.gz")
    if fasta_files:
        return fasta_files[0]
    else:
        raise ValueError(f"No FNA file found in {sample_path}")

rule all:
    input:
        expand("{sample_path}/genomad_output", sample_path=[sample_dict[sample] for sample in SAMPLES])

# Modify rules to use sample_path directly
rule copy_reference:
    input:
        ref = GENOMAD_DB
    output:
        directory("{sample_path}/genomad_db")
    threads: 1
    shell:
        "mkdir -p $(dirname {output}) && cp -r {input.ref} {output}"

rule run_genomad:
    input:
        fna = find_fna,
        database = "{sample_path}/genomad_db"  # This ensures copy_reference is run first
    output:
        directory("{sample_path}/genomad_output")
    threads: 1
    shell:
        """
        genomad end-to-end {input.fna} {output} {input.database}
        """

# Add cleanup rule to remove databases
rule cleanup:
    input:
        expand("{sample_path}/genomad_output", sample_path=[sample_dict[sample] for sample in SAMPLES])
    output:
        touch("cleanup.done")
    threads: 1
    shell:
        """
        # Remove all the copied database directories
        for path in {input}; do
            sample_path=$(dirname "$path")
            echo "Removing database for $sample_path"
            rm -rf "$sample_path"/genomad_db
        done
        """

# Add a cleanup target
rule cleanup_all:
    input:
        "cleanup.done"
