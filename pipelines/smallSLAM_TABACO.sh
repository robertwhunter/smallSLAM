#!/bin/sh

####################################################################
#### READ-ME #######################################################
####################################################################
##
## An add-on to the main smallSLAM pipeline
##
##


# Set grid Engine options:
#$ -N sS_TABACO
#$ -wd /exports/eddie/scratch/rhunter3/smallSLAM_data/INPUT_DIR/
#$ -o /exports/eddie/scratch/rhunter3/smallSLAM_data/INPUT_DIR/
#$ -e /exports/eddie/scratch/rhunter3/smallSLAM_data/INPUT_DIR/
#$ -l h_rt=00:30:00
#$ -l h_vmem=8G
#$ -pe sharedmem 4
#$ -m bea -M robert.hunter@ed.ac.uk



####################################################################
#### SET-UP ########################################################
####################################################################
##
##

set_threshold_parent=100
set_threshold_cycle=50
mod2a=1
mod3a=1
mod6a=1


#### Initialise the environment modules

. /etc/profile.d/modules.sh
module load R


#### Write out

echo "Starting smallSLAM_TABACO pipeline"
echo "" 
echo "" 
echo "Running modules:" 
echo "----------------"
if (( $mod2a == 1 )); then echo "Module 2a - group into families (parents and children)"; fi
if (( $mod3a == 1 )); then echo "Module 3a - calculate thetas"; fi
if (( $mod6a == 1 )); then echo "Module 6a - summarise"; fi
echo ""
echo ""
echo "Script parameters:"
echo "----------------"
echo "Threshold cycle = $set_threshold_cycle"
echo ""
echo ""
echo "Input files:"
echo "----------------"
ls -ho Unique/*.uniq
echo ""
echo ""




####################################################################
#### COUNT #########################################################
####################################################################
##
##

#### Module 2a
if (( $mod2a == 1 ))
then

t="$(date)"
echo "...starting module 2a at $t..."
parallel "Rscript /home/rhunter3/smallSLAM_scripts/2a_families_TABACO.R {} $set_threshold_parent $set_threshold_cycle" ::: Unique/*.uniq

mkdir Families_TABACO
mv Unique/*_slam_uniq.*.csv Families_TABACO

fi


#### Module 3a
if (( $mod3a == 1 ))
then

t="$(date)"
echo "...starting module 3a at $t..."
parallel "Rscript /home/rhunter3/smallSLAM_scripts/3_parents.R {}" ::: Families_TABACO/*_slam_uniq.*.csv

mkdir Parents_TABACO
mv Families_TABACO/*_slam_parents* Parents_TABACO

fi


#### Module 6a
if (( $mod6a == 1 ))
then

t="$(date)"
echo "...starting module 6a at $t..."

Rscript /home/rhunter3/smallSLAM_scripts/6a_unify_TABACO.R Parents_TABACO/

mkdir Summary_TABACO
mv Parents_TABACO/*summary.csv Summary_TABACO

fi


#### Close
t="$(date)"
echo "...finished at $t."
echo ""
echo ""
echo "Output files:"
echo "----------------"
ls -ho Summary_TABACO/*.csv
