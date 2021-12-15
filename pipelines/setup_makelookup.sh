#!/bin/sh
# make lookup table from genomes (only once)

# Set grid Engine options:
#$ -N makelookup
#$ -wd <insert wd>
#$ -e <insert wd>/Logs/
#$ -o <insert wd>/Logs/
#$ -l h_rt=00:10:00
#$ -l h_vmem=2G
#$ -pe sharedmem 1
#$ -m bea -M <insert email>
#$ -V


for a in *.fa; do ~/smallSLAM_scripts/0c_make_lookup.bash $a; done
cat *.fa.lookup > Lookup_table.tsv
sed 's/^.//' Lookup_table.tsv > tmp # to remove > at the start of each line
mv tmp Lookup_table.tsv 
