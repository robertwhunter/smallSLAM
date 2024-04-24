#!/bin/sh

####################################################################
#### READ-ME #######################################################
####################################################################
##
## An add-on to the main smallSLAM pipeline
##
##


# Set grid Engine options:
#$ -N <insert job name>_TREFOIL0
#$ -wd <insert wd>
#$ -e <insert wd>/Logs/
#$ -o <insert wd>/Logs/
#$ -l h_rt=08:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 4
#$ -m bea -M <insert email>
#$ -V




####################################################################
#### SET-UP ########################################################
####################################################################
##
##

mod7=1
set_lib_threshold=2
set_cpm_threshold=5

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
echo "lib threshold = $set_lib_threshold"
echo "cpm threshold = $set_cpm_threshold"

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

Rscript /home/rhunter3/smallSLAM_scripts/7_TREFOIL0.R "Unique/" $set_lib_threshold $set_cpm_threshold

fi


#### Close
t="$(date)"
echo "...finished at $t."
echo ""
echo ""
echo "Output files:"
echo "----------------"
ls -ho TREFOIL0*.csv
