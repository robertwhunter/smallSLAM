#!/bin/sh

#$ -N <insert job name>_trim
#$ -wd <insert wd>
#$ -e <insert wd>/Logs/
#$ -o <insert wd>/Logs/
#$ -l h_rt=02:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 4
#$ -m bea -M <insert email>
#$ -V

####################################################################
#### READ-ME #######################################################
####################################################################
##
## Have input files as .fastq in -wd; second reads must be in same directory (as .read2)
## Before running, set grid engine options and script parameters
## NB e-mail and conda directory are set here as environmental variables


####################################################################
#### SET-UP ########################################################
####################################################################
##
##

set_paired=0
set_dummyrun=0
set_dummysize=1000000
set_ADAP_FOR="TGGAATTCTCGGGTGCCAAGG"
set_ADAP_REV="GTTCAGAGTTCTACAGTCCGACGATC"
set_conda_dir=$DIR_miniconda  # no trailing slash



#### Write out

echo "Starting trimming pipeline"
echo "" 
echo "" 
echo "Script parameters:"
echo "----------------"
echo "Paired = $set_paired"
echo "Dummy run = $set_dummyrun"
echo "Dummy size = $set_dummysize" 
echo ""
echo ""
echo "Input fastq files:"
echo "----------------"
ls -ho *.fastq *.read2
echo ""
if (( $set_dummyrun == 1 )); then echo "Running as dummy run"; fi
echo ""


####################################################################
#### COPY FASTQ FILES ##############################################
####################################################################
##
##

t="$(date)" 
echo "...starting fastq prep at $t..."

mkdir Fastq/

if (( $set_dummyrun == 1 )) 

then
  parallel "head -$set_dummysize {} > Fastq/{}" ::: *.fastq 
  if (( $set_paired == 1 )); then parallel "head -$set_dummysize {} > Fastq/{}" ::: *.read2; fi

else
  parallel "cp {} Fastq/{}" ::: *.fastq 
  if (( $set_paired == 1 )); then parallel "cp {} Fastq/{}" ::: *.read2; fi

fi


####################################################################
#### TRIM ##########################################################
####################################################################
##
##

t="$(date)" 
echo "...starting trimming at $t..."

source $set_conda_dir/bin/activate env_CUTADAPT


#### Trim with cutadapt

if (( $set_paired == 1 ))
then

echo "Not yet written code for paired reads."

else

for f in Fastq/*.fastq 
do
  cutadapt -a "$set_ADAP_FOR" -o "$f.trim1.fq" --minimum-length 23 "$f"
  cutadapt -u 4 -u -4 -m 15 -o "$f.trim.fq" "$f.trim1.fq"
done

fi 


#### QC on trimmed files

rm Fastq/*.trim1.fq
mkdir Trim_qc
mv Fastq/*.trim.fq Trim_qc

parallel "fastqc {}" ::: Trim_qc/*.trim.fq
mkdir Trim
mv Trim_qc/*.trim.fq Trim

multiqc Trim_qc -n Trim_multiqc
mkdir Trim_multiqc
mv Trim_multiqc.html Trim_multiqc_data Trim_multiqc





####################################################################
#### CLOSE #########################################################
####################################################################
##
##

conda deactivate

t="$(date)"
echo "...finished at $t."
echo ""
echo ""
echo "Output files:"
echo "----------------"
ls -ho Trim/*.trim.fq
