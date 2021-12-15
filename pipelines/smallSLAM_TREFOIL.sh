#!/bin/sh

####################################################################
#### READ-ME #######################################################
####################################################################
##
## An add-on to the main smallSLAM pipeline
##
##


# Set grid Engine options:
#$ -N sS_TREFOIL
#$ -wd /exports/eddie/scratch/rhunter3/smallSLAM_data/<input dir>/
#$ -o /exports/eddie/scratch/rhunter3/smallSLAM_data/<input dir>/
#$ -e /exports/eddie/scratch/rhunter3/smallSLAM_data/<input dir>/
#$ -l h_rt=00:30:00
#$ -l h_vmem=8G
#$ -m bea -M robert.hunter@ed.ac.uk



####################################################################
#### SET-UP ########################################################
####################################################################
##
##

# set_lib_pos="podo_2,podo_6"
# set_lib_neg="podo_3,podo_4,podo_7,podo_8"

set_lib_pos=""
set_lib_neg=""
mod7=1


#### Initialise the environment modules

. /etc/profile.d/modules.sh
module load R


#### Write out

echo "Starting smallSLAM_TREFOIL pipeline"
echo "" 
echo "" 
echo "Running modules:" 
echo "----------------"
if (( $mod7 == 1 )); then echo "Module 7 - TREFOIL"; fi
echo ""
echo ""
echo "Script parameters:"
echo "----------------"
echo "Threshold cycle = $set_threshold_cycle"
echo "Positive libraries = $set_lib_pos"
echo "Negative libraries = $set_lib_neg"

# echo "Library threshold (positive) = $set_lib_threshold_pos"
# echo "Library threshold (negative) = $set_lib_threshold_neg"
# echo "cpm threshold (positive) = $set_cpm_threshold_pos"
# echo "cpm threshold (negative) = $set_cpm_threshold_neg"

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

#### Module 7
if (( $mod7 == 1 ))
then

t="$(date)"
echo "...starting module 7 at $t..."

Rscript /home/rhunter3/smallSLAM_scripts/7_TREFOIL.R "Unique/" $set_lib_neg $set_lib_pos
mv TREFOIL.csv TREFOIL_inverse.csv

Rscript /home/rhunter3/smallSLAM_scripts/7_TREFOIL.R "Unique/" $set_lib_pos $set_lib_neg

fi


#### Close
t="$(date)"
echo "...finished at $t."
echo ""
echo ""
echo "Output files:"
echo "----------------"
ls -ho TREFOIL*.csv
