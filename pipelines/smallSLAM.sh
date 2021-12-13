#!/bin/sh

#$ -N smallSLAM
#$ -wd <insert wd>
#$ -e <insert wd>/Logs/
#$ -o <insert wd>/Logs/
#$ -l h_rt=02:00:00
#$ -l h_vmem=8G
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

set_threshold_parent=100
set_genomes_dir=$DIR_genome    # no trailing slash
set_conda_dir=$DIR_miniconda   # no trailing slash
mod1=0
mod2=0
mod3=0
mod4=0
mod5=0


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
echo "Genome dir = $set_genomes_dir="
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
parallel "awk 'NR%4==2' {} | sort | uniq -c | sort -nr | cat -n > {.}.uniq" ::: Trim/*.fq

# awk 'NR%4==2' = filter out sequences only
 # sort = sort file
  # uniq -c = find unique lines and include counts
   # sort -nr = sort in reverse order by count
    # cat -n = add row numbers

for u in Trim/*.uniq
do
echo "rank,count,sequence" > tmp
awk '{$2=$2};1' $u | sed 's/ /,/g' >> tmp
mv tmp $u
done

# awk '{$2=$2};1' to collapse multiple spaces into a single space
  # sed 'sed/ /,/g' to convert spaces into commas


mkdir Unique
mv Trim/*.uniq Unique
parallel "~/smallSLAM_scripts/1_trim_uniq.bash {}" ::: Unique/*.uniq

fi


#### Module 2
if (( $mod2 == 1 ))
then

t="$(date)"
echo "...starting module 2 at $t..."
parallel "Rscript /home/rhunter3/smallSLAM_scripts/2_families.R {} $set_threshold_parent" ::: Unique/*.uniq

mkdir Families
mv Unique/*_slam_uniq.*.csv Families

fi


#### Module 3
if (( $mod3 == 1 ))
then

t="$(date)"
echo "...starting module 3 at $t..."
parallel "Rscript /home/rhunter3/smallSLAM_scripts/3_parents.R {}" ::: Families/*_slam_uniq.*.csv

mkdir Parents
mv Families/*_slam_parents* Parents

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
#
#

parallel "~/smallSLAM_scripts/4_make_fasta.bash {}" ::: Parents/*.index.csv
mkdir Mapping
mv Parents/*dummy* Mapping


#### MAP
#
#

source $set_conda_dir/bin/activate env_MAP

# BOWTIE OPTIONS
#
# --no-unal = suppress SAM records for reads that fail to align
# --no-hd = suppress SAM header lines (starting with @)
# --reorder = SAM records are printed in order corresponding to reads in input file
# --sensitive = reasonable default settings
# -N = number of mismatches allowed in seed alignment
# -L = lenght of seed substrings


# MAP AND THEN MERGE IN SENSIBLE GENE NAMES FROM LOOKUP TABLE

for f in Mapping/*dummy.fasta
do
  parallel "bowtie2 -f $f -x {.} --no-unal --no-hd --reorder --sensitive -N 1 -L 18 | cut -f1,3 > $f.{/.}.hits" ::: $set_genomes_dir/*.fa

  for g in $f*.hits 
  do
    if [ -s $g ]
    then
      csvtk join -T -t -H -f "2;1" $g $set_genomes_dir/Lookup_table.tsv | cut -f1,3 > $g.2
    fi
  done

  awk 'NR%2==0' $f > $f.sequences


# MERGE IN HITS TO SINGLE FILE

  cat $f.sequences > $f.all_biotypes.tsv

  function_merge() {
    if [ -s $1 ]
    then
      csvtk join -t -T -H -k --na 0 $f.all_biotypes.tsv $1 > tmp    ## NB previous usage --fill instead of --na
      mv tmp $f.all_biotypes.tsv
    else
      csvtk mutate2 -H -t $f.all_biotypes.tsv -e 0 > tmp
      mv tmp $f.all_biotypes.tsv
    fi
  }

  function_merge $f.*genome*.hits.2
  function_merge $f.*miRNA*.hits.2
  function_merge $f.*pre-miRNA*.hits.2
  function_merge $f.*rRNA*.hits.2
  function_merge $f.*lncRNA*.hits.2
  function_merge $f.*pc_transcripts*.hits.2
  function_merge $f.*piRNA*.hits2
  function_merge $f.*snoRNA*.hits2
  function_merge $f.*snRNA*.hits2
  function_merge $f.*tRNA*.hits.2
  function_merge $f.*vaultRNA*.hits.2
  function_merge $f.*YRNA*.hits.2

  csvtk add-header -t $f.all_biotypes.tsv -n Sequence,Genome,miRNA,pre-miRNA,rRNA,lncRNA,pctranscripts,piRNA,snoRNA,snRNA,tRNA,vaultRNA,YRNA > tmp
  mv tmp $f.all_biotypes.tsv

done
fi

conda deactivate


#### Module 5
if (( $mod5 == 1 ))
then

t="$(date)"
echo "...starting module 5 at $t..."

mkdir Summary
cp Mapping/*all_biotypes.tsv Summary/
cp Parents/*index.csv Summary/

parallel "Rscript /home/rhunter3/smallSLAM_scripts/5_summary.R {}" ::: Summary/*index.csv

Rscript /home/rhunter3/smallSLAM_scripts/6_unify.R Summary/

fi


#### Close
t="$(date)"
echo "...finished at $t."
echo ""
echo ""
echo "Output files:"
echo "----------------"
ls -ho Summary/*_summary.csv
