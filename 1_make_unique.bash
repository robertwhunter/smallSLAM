#!/bin/bash

parallel "awk 'NR%4==2' {} | sort | uniq -c | sort -nr | cat -n > {.}.uniq" ::: Fastp/*.fq

# awk 'NR%4==2' = filter out sequences only
 # sort = sort file
  # uniq -c = find unique lines and include counts
   # sort -nr = sort in reverse order by count
    # cat -n = add row numbers

for u in Fastp/*.uniq
do
echo "rank,count,sequence" > tmp
awk '{$2=$2};1' $u | sed 's/ /,/g' >> tmp
mv tmp $u
done

# awk '{$2=$2};1' to collapse multiple spaces into a single space
  # sed 'sed/ /,/g' to convert spaces into commas
