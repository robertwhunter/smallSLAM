#!/bin/sh
# index genomes (only once)

# Set grid Engine options:
#$ -N index_genomes
#$ -wd <insert wd>
#$ -e <insert wd>/Logs/
#$ -o <insert wd>/Logs/
#$ -l h_rt=24:00:00
#$ -l h_vmem=64G
#$ -pe sharedmem 2
#$ -m bea -M <insert email>
#$ -V

set_conda_dir=$DIR_miniconda

source $set_conda_dir/bin/activate env_MAP
parallel "bowtie2-build {} {.}" ::: *.fa
conda deactivate

