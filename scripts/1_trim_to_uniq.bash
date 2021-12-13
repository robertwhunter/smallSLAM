#!/bin/bash

awk 'NR%4==2' $1 | sort | uniq -c | sort -nr | cat -n > $1.uniq 

# awk 'NR%4==2' = filter out sequences only
 # sort = sort file
  # uniq -c = find unique lines and include counts
   # sort -nr = sort in reverse order by count
    # cat -n = add row numbers


echo "rank,count,sequence" > $1.tmp

awk '{$2=$2};1' $1.uniq | sed 's/ /,/g' >> $1.tmp
mv $1.tmp $1.uniq

# awk '{$2=$2};1' to collapse multiple spaces into a single space
  # sed 'sed/ /,/g' to convert spaces into commas
