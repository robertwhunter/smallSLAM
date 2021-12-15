#!/bin/sh
# make lookup table from genomes (only once)

# Set grid Engine options:
#$ -N make_lookup
#$ -wd /exports/eddie/scratch/rhunter3/Genomes_mouse_old/
#$ -o /exports/eddie/scratch/rhunter3/Genomes_mouse_old/
#$ -e /exports/eddie/scratch/rhunter3/Genomes_mouse_old/
#$ -l h_rt=00:10:00  
#$ -l h_vmem=2G    
#$ -pe sharedmem 1  
#$ -m bea -M robert.hunter@ed.ac.uk

for a in *.fa; do ~/smallSLAM_scripts/make_lookup.bash $a; done
cat *.fa.lookup > Lookup_table.tsv
sed 's/^.//' Lookup_table.tsv > tmp # to remove > at the start of each line
mv tmp Lookup_table.tsv 
