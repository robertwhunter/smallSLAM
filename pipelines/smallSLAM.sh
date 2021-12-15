#!/bin/sh

#$ -N <insert job name>_smallSLAM
#$ -wd <insert wd>
#$ -e <insert wd>/Logs/
#$ -o <insert wd>/Logs/
#$ -l h_rt=08:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 4
#$ -m bea -M <insert email>
#$ -V


####################################################################
#### READ-ME #######################################################
####################################################################
##
## Input files should be trimmed .fq files in `Trim` directory
## Genome directory must contain .fa, Bowtie index files and lookup tables
##
## Before running, set grid engine options and script parameters
## NB Conda directory and genome directory are set here as environmental variables
##
## Then select modules to run
##


####################################################################
#### SET-UP ########################################################
####################################################################
##
##

set_threshold_parent=200
set_genomes_dir=$DIR_genome    # no trailing slash
set_conda_dir=$DIR_miniconda   # no trailing slash
mod1=1 # unique reads
mod2=1 # families
mod3=1 # parents 
mod4=1 # map 
mod5=1 # summarise


#### Initialise the environment modules

. /etc/profile.d/modules.sh
module load R


#### Write out

echo "Starting smallSLAM pipeline"
echo "" 
echo "" 
echo "Running modules:" 
echo "----------------"
if (( $mod1 == 1 )); then echo "Module 1 - count unique reads"; fi
if (( $mod2 == 1 )); then echo "Module 2 - group into families (parents and children)"; fi
if (( $mod3 == 1 )); then echo "Module 3 - calculate thetas"; fi
if (( $mod4 == 1 )); then echo "Module 4 - map small RNA reads"; fi
if (( $mod5 == 1 )); then echo "Module 5 - reconcile mapping and count data"; fi
echo ""
echo ""
echo "Script parameters:"
echo "----------------"
echo "Parent threshold = $set_threshold_parent"
echo "Genome dir = $set_genomes_dir"
echo ""
echo ""
echo "Input fastq files:"
echo "----------------"
ls -ho Fastq/*.fastq
echo ""
echo ""


####################################################################
#### COUNT #########################################################
####################################################################
##
##

#### Module 1
if (( $mod1 == 1 ))
then

t="$(date)" 
echo "...starting module 1 at $t..."

parallel "~/smallSLAM_scripts/1_trim_to_uniq.bash {}" ::: Trim/*.fq

mkdir Unique
mv Trim/*.uniq Unique

fi


#### Module 2
if (( $mod2 == 1 ))
then

t="$(date)"
echo "...starting module 2 at $t..."
parallel "Rscript /home/rhunter3/smallSLAM_scripts/2_families.R {} $set_threshold_parent" ::: Unique/*.uniq

mkdir Families
mv Unique/*families*.csv Families

fi


#### Module 3
if (( $mod3 == 1 ))
then

t="$(date)"
echo "...starting module 3 at $t..."
parallel "Rscript /home/rhunter3/smallSLAM_scripts/3_parents.R {}" ::: Families/*families*.csv

mkdir Parents
mv Families/*parents* Parents

fi


####################################################################
#### MAP ###########################################################
####################################################################
##
##

#### Module 4
if (( $mod4 == 1 ))
then

t="$(date)" 
echo "...starting module 4 at $t..."

#### MAKE DUMMY INPUT FASTA FILES
parallel "~/smallSLAM_scripts/4a_make_fasta.bash {}" ::: Parents/*.index.csv
mkdir Mapping
mv Parents/*dummy* Mapping

#### MAP
source $set_conda_dir/bin/activate env_MAP
for f in Mapping/*dummy.fasta; do ~/smallSLAM_scripts/4b_sRNA_map.bash $f $set_genomes_dir; done
conda deactivate

fi


#### Module 5
if (( $mod5 == 1 ))
then

t="$(date)"
echo "...starting module 5 at $t..."

mkdir Summary
cp Mapping/*all_biotypes.tsv Summary/
cp Parents/*index.csv Summary/

parallel "Rscript /home/rhunter3/smallSLAM_scripts/5_summary.R {}" ::: Summary/*index.csv

fi


#### Close
t="$(date)"
echo "...finished at $t."
echo ""
echo ""
echo "Output files:"
echo "----------------"
ls -ho Summary/*_scount.csv
