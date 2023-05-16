#!/bin/bash

# This script maps reads using minimap2

# Arguments required:
        # 1. reference genome	
        # 2. read type ('short' or 'long')
		# 3. fastq file of (forward or single) reads
		# 4. fastq file of reverse reads (optional, if paired)

# Error catching

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] ; then
        echo "ERROR: Insufficient arguments given, please provide: 1. reference genome accession, 2. read type ('short' or 'long'), 3. fastq file/s of reads" >&2
        exit 1
fi

if [ ! -f "./rawdata/reference_genomes/${1}.fa" ] ; then
		echo "ERROR: No reference genome found for that accession number in directory ./rawdata/reference_genomes." >&2
		exit 1
fi

if [ $2 != "short" ] && [ $2 != "long" ] ; then
        echo "ERROR: Must specify if reads are (short) or (long)." >&2
        exit 1
fi

if [ ! -f "${3}" ] ; then
        echo "ERROR: Fastq file/s ${3} not found." >&2
 		exit 1
fi

if [ -z "$4" ] ; then
	paired=0
else 
	paired=1
fi

if [ $paired == 1 ] && [ ! -f "${4}" ] ; then
	echo "ERROR: Fastq file ${4} not found." >&2
	exit 1
fi

# Get read/s accession number from fastq filename and create output folder

read_accession=$(basename $3 .fastq | cut -d_ -f1)
mkdir ./mapping/${read_accession} 

## Index reference sequence

echo "Indexing reference genome $1 ..."

minimap2 -d mapping/${read_accession}/ref.mmi ./rawdata/reference_genomes/${1}.fa

## Mapping reads 

# Short, single-end reads

if [ $2 == "short" ] && [ $paired == 0 ] ; then
	echo "Mapping short, single-end reads..."
	minimap2 -ax sr ./rawdata/reference_genomes/${1}.fa ${3} > mapping/${read_accession}/${read_accession}.sam
fi

# Short, paired-end reads

if [ $2 == "short" ] && [ $paired == 1 ] ; then
	echo "Mapping short, paired-end reads..."
	minimap2 -ax sr ./rawdata/reference_genomes/${1}.fa ${3} ${4} > mapping/${read_accession}/${read_accession}.sam
fi

# Long reads (Nanopore technology)
if [ $2 == "long" ] ; then
	echo "Mapping long Nanopore reads..."
	minimap2 -ax map-ont ./rawdata/reference_genomes/${1}.fa ${3} > mapping/${read_accession}/${read_accession}.sam
fi
