#!/bin/bash

input_file=$1
cut -f2 -d, $input_file | sed 's/"//g' | awk '{print ">"$1"\n"$1}' | tail -n +3 > $input_file.dummy.fasta
