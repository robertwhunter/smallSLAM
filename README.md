# smallSLAM

## Introduction 

smallSLAM is an analysis pipeline for small RNA SLAMseq data.  

[SLAMseq](https://www.nature.com/articles/nmeth.4435) is a method for detecting metabolic labelling in RNA.  4-thiouridine is used to label RNA and then RNA is treated with an alkylating agent (iodoacetamide).  During the reverse transcriptase step of RNA library preparation, bulky alkyl groups interfere with Watson-Crick base-pairing so that sites of 4TU incorporation are marked by T>C conversions in the final RNAseq dataset.  

Existing analysis pipelines are capable of mapping and quantifying T>C conversions in large RNA molecules (e.g. [SLAM-DUNK pipeline for mRNA](https://t-neumann.github.io/slamdunk/)).  

The smallSLAM pipeline has been designed to quantify and map T>C conversions in small RNA SLAMseq datasets.  These require a different approach to T>C quantification (due to a high proportion of duplicated reads and a low number of Ts per read) and a mapping approach that is optimised for small RNA species.  

Our general approach is shown here:

![](smallSLAM.png)


## Implementation

We will add additional documentation in late 2021.  


## Set-up

### Genome data

Need to set up a directory with reference genomes.  To do this: in .fasta format.  These then need to be:  

1) download genome sequences in .fasta format (or use `setup_pullgenomes.sh` script to do this)
2) generate Bowtie index files (.bt2) (use `setup_indexgenomes.sh` script) 
3) generate a lookup table (`Lookup_table.tsv`) so that gene names can be translated into intuitive ones (use `setup_makelookup.sh` script)


### Input data
Input data in .fastq format.  First ensure reads are trimmed (e.g. using `trim_TriLink.sh` or `trim_PerkinElmer.sh` - and ensure correct adapter sequences being used for these scripts).  Then run the `smallSLAM.sh` pipeline.  


### Analysis .Rmd

After running the smallSLAM pipeline, run `smallSLAM_render.R` and then call the `render_smallSLAM(fname)` function, where `fname` is the name of the parent data directory.  

This data directory should contain the following subdirectories:  

- `input` - containing a `metadata.csv` and `exp_setup.txt` (freetext description of the experiment)
- `Trim_multiqc` from smallSLAM pipeline
- `Summary` from smallSLAM pipeline
- `output` - empty but will be populated when analysis is rendered


The `metadata.csv` should contain the following columns:  

- `library`: library name  
- `group`: experimental group  
- plus any additional columns (often Cre, UPRT and 4TU, sample type etc.)
