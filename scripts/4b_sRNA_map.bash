#!/bin/bash

######################################################
######################################################
####
#### DEFINE VARIABLES AND FUNCTIONS 
####
####

f=$1
genomes_dir=$2

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


######################################################
######################################################
####
#### MAP
####
####

# BOWTIE OPTIONS
#
# --no-unal = suppress SAM records for reads that fail to align
# --no-hd = suppress SAM header lines (starting with @)
# --reorder = SAM records are printed in order corresponding to reads in input file
# --sensitive = reasonable default settings
# -N = number of mismatches allowed in seed alignment
# -L = lenght of seed substrings


parallel "bowtie2 -f $f -x {.} --no-unal --no-hd --reorder --sensitive -N 1 -L 18 | cut -f1,3 > $f.{/.}.hits" ::: $genomes_dir/*.fa


######################################################
######################################################
####
#### LOOK-UP SENSIBLE GENE NAMES
####
####

for g in $f*.hits 
  do
    if [ -s $g ]
    then
      csvtk join -T -t -H -f "2;1" $g $genomes_dir/Lookup_table.tsv | cut -f1,3 > $g.2
    fi
  done

awk 'NR%2==0' $f > $f.sequences


######################################################
######################################################
#### MERGE IN HITS TO SINGLE FILE
####

cat $f.sequences > $f.all_biotypes.tsv

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