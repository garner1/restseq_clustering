#!usr/bin/env bash

datadir="/home/garner1/Work/dataset/fastq2cloud/hg38"
#####
# # SPLIT THE GENOME INTO DOCUMENTS OF CONSECUTIVE NON-N CHARACTERS, WHILE SQUEEZING Ns
# rm -f "$datadir"/input/*
wd=$PWD
# cd /home/garner1/igv/genomes/hg38_byChromosome
# parallel "cat {} | LC_ALL=C grep -v '>' |tr -d '\n' | tr -s 'N' | tr '[:lower:]' '[:upper:]' > $datadir/input/{.}.read" ::: *.fa
# parallel "echo '' >> {}" ::: "$datadir"/input/*.read # add an additional new line at the end of the file
# cd "$datadir"/input
# parallel "cat {} | tr 'N' '\n' | awk 'length($1) > 100' > {.}.multiread" ::: *.read # filter out short (<100bp) contigs
# parallel "sed -i '/^$/d' {}" ::: *.multiread
# cd $wd
#####

#####
# PREPARE KMER TABLE
# g++ -std=c++11 ./kmers.cpp -o ./kmers # compile kmers
# wd=$PWD
# cd "$datadir"/input
# echo "Make reverse complement ..."
# parallel "cat {} | rev | tr 'ATCG' 'TAGC' > {}.RC" ::: *.read
# echo "Count kmers ..."
# rm -f "$datadir"/MCmodel/6mer/*
# concatenate plus and minus strands, althought the junction is not real and will be counted, but is a small perturbation
# parallel "cat {} {}.RC |tr -d '\n'| $wd/kmers 6 6 |LC_ALL=C grep -v 'N' | awk 'NF == 2' > ../MCmodel/6mer/{.}.tsv" ::: *.read 
# cd "$datadir"/MCmodel/6mer
# bash $wd/jelly_f2.sh chr1.tsv 6 1.0
# parallel bash $wd/jelly_f2.sh {} 6 1.0 ::: *.tsv
# rm -f *kmer* 
# cd $wd
# ####

####
# SEGMENT THE GENOME
g++ -std=c++11 ./tokenizer_withMean.cpp -o ./mean & pid1=$! # compile the tokenizer
g++ -std=c++11 ./tokenizer_withMean_RC.cpp -o ./meanRC & pid2=$! # compile the tokenizer
wait $pid1
wait $pid2
wd=$PWD
cd "$datadir"/input
rm -f ../docs/*
# THIS IS TOO LONG WHEN RUN ON THE PRESENT MODEL: SPLIT CHROMOSOMES
time parallel "$wd/mean {} ~/Work/dataset/fastq2cloud/hg38/MCmodel/6mer/{.}.tsv.table | cut -d' ' -f2- > ../docs/{.}.docs" ::: chr*.multiread 
time parallel "$wd/meanRC {} ~/Work/dataset/fastq2cloud/hg38/MCmodel/6mer/{.}.tsv.table | cut -d' ' -f2- > ../docs/{.}.docs_RC" ::: chr*.multiread 

cd $wd

# python /home/garner1/Work/pipelines/fastq2cloud/structure/word2vector.py ~/Work/dataset/fastq2cloud/hg19/corpus



# parallel "cat {} |paste - -| cut -f2|cut -d' ' -f2,5|LC_ALL=C sort -u | cut -d' ' -f2 > ../corpus/{}.dedup" ::: bicro36_XZ37_*.fa

# time parallel "./mean {} /home/garner1/Work/dataset/fastq2cloud/MCmodel/6mer/ > {}_sentences" ::: /home/garner1/Work/dataset/restseq/XZ37/corpus/*.dedup   

# time parallel "./meanRC {} /home/garner1/Work/dataset/fastq2cloud/MCmodel/6mer/ > {}_sentences.RC" ::: /home/garner1/Work/dataset/restseq/XZ37/corpus/*.dedup

# parallel "paste {}_sentences {}_sentences.RC > {}.mergedStrands"  ::: *.fa.dedup

# parallel "cat {}.mergedStrands | tr '\t' '\n'|cut -d',' -f2-|paste - -|tr -d ]|tr '\t' ','|awk '{print \"[\"\$0\"]\"}'|grep -v N > {.}docs" ::: *.fa.dedup

# parallel "cat {} | tr -d \"'[]\" | tr ',' '\n' | LC_ALL=C sort | LC_ALL=C uniq -c |awk '{print \$1\"\t\"\$2}' > ../corpus_summary/{}.count_word" ::: *.docs

# parallel "awk '{print \$2}' {} > {}.vocabulary" ::: *.count_word

# parallel python ~/Work/pipelines/fastq2cloud/structure/termDocumentMatrix.py {} {}.count_word.vocabulary 25 ::: *.docs

# parallel python ~/Work/pipelines/fastq2cloud/structure/cooccurrenceMat.py {} ::: *.pickle
