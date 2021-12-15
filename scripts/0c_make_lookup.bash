#make_lookup.bash
#!/bin/bash

f=$1

grep ^">" $f | cut -f 1 -d " " > temp1
grep ^">" $f | cut -f 2- -d " " > temp2

paste temp1 temp2 > $f.lookup
rm temp1 temp2
