#!/usr/bin/env bash

export LC_ALL=C

file=$1
dim=$2
alpha=$3			# alpha estimator in [0,1] 

awk -v dim="$dim" '{OFS="\t";print $2,substr($1,1,dim-1),substr($1,dim,1)}' "$file" |
sort -k2,2 > "$file"_count-kmer-kmer # produce the count per k-1 to 1 transitions

awk -v dim="$dim" '{OFS="\t";print $2,substr($1,1,dim-1)}' "$file" |
datamash -s -g 2 sum 1 > "$file"_kmer-sumCount # produce the normalization for each k-1 mer

join -1 2 -2 1 -o 1.2,1.3,1.1,2.2 "$file"_count-kmer-kmer "$file"_kmer-sumCount |
awk -v alpha=$alpha '{OFS="\t"; print $1$2,-log(($3+alpha)/($4+alpha*4))}' > "$file".table # use the alpha-estimator

