#!/bin/sh
# download and then index genomes (only once)

# Set grid Engine options:
#$ -N pull_genomes
#$ -wd <insert wd>
#$ -e <insert wd>/Logs/
#$ -o <insert wd>/Logs/
#$ -l h_rt=12:00:00 
#$ -l h_vmem=2G     
#$ -pe sharedmem 4  
#$ -l h_rt=08:00:00
#$ -l h_vmem=16G
#$ -m bea -M <insert email>
#$ -V

#### INITIALiSE ENVIRONMENT MODULES

. /etc/profile.d/modules.sh
module load R


#### DOWNLOAD FASTAS

## small RNA
Rscript /home/rhunter3/smallSLAM_scripts/0a_pull_smallRNA_setup.R
parallel "Rscript /home/rhunter3/smallSLAM_scripts/0b_pull_smallRNA_fasta.R {}" ::: *_split_*.csv
rm *_split_*.csv

## pc transcripts and genome
curl -s "ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M27/gencode.vM27.pc_transcripts.fa.gz" | gunzip > pc_transcripts.fa
curl -s "ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M27/GRCm39.genome.fa.gz" | gunzip > genome.fa