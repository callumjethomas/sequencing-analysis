#!/bin/bash

# 1. fastq file 1
# 2. fastq file 2 (optional)

# Error and argument checking
if [ -z "$1" ] ; then
        echo "ERROR: Insufficient arguments given, please provide at least one fastq file to assemble from." >&2
        exit 1
fi

outdir=$(echo $1 | cut -d "/" -f 2)

# Single read assembly
if [ -z "$2" ] ; then
		echo "Only one fastq file entered, processing as single reads..."
		echo "Performing de novo assembly with SPAdes..."
		spades --careful -s $1 -o assemblies/$outdir/spades

else
# Paired read assembly
		echo "Processing $1 and $2 as paired reads..."
		echo "Performing de novo assembly with SPAdes..."
		spades --careful -1 $1 -2 $2 -o assemblies/$outdir/spades
fi

echo "Assembly complete."

