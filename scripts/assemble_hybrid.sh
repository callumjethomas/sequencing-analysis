#!/bin/bash

# 1. nanopore fastq file
# 2. illumina fastq file 1
# 3. illumina fastq file 2 (optional)

# Error and argument checking
if [ -z "$1" ] || [ -z "$2" ] ; then
        echo "ERROR: Insufficient arguments given, please provide at least one Nanopore and one Illumina .fastq file to assemble from." >&2
        exit 1
fi

outdir1=$(echo $1 | cut -d "/" -f 2)
outdir2=$(echo $2 | cut -d "/" -f 2)

# Single read assembly
if [ -z "$3" ] ; then
		echo "Only one fastq file entered, processing as single reads..."
		echo "Performing de novo assembly with SPAdes..."
		spades --careful --nanopore $1 -s $2 -o assemblies/hybrid/${outdir1}_${outdir2} 

else
# Paired read assembly
		echo "Processing $1 and $2 as paired reads..."
		echo "Performing de novo assembly with SPAdes..."
		spades --careful --nanopore $1 -1 $2 -2 $3 -o assemblies/hybrid/${outdir1}_${outdir2}
fi

echo "Assembly complete."

