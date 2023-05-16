#!/bin/bash

# This script maps reads using bwa-mem2

# Arguments required:
        # 1. reference genome	
		# 2. fastq file of (forward or single) reads
		# 3. fastq file of reverse reads (optional, if paired)

# Error catching

if [ -z "$1" ] || [ -z "$2" ] ; then
        echo "ERROR: Insufficient arguments given, please provide: 1. reference genome accession, 2. fastq file/s of reads" >&2
        exit 1
fi

if [ ! -f "./rawdata/reference_genomes/${1}.fa" ] ; then
		echo "ERROR: No reference genome found for that accession number in directory ./rawdata/reference_genomes." >&2
		exit 1
fi

if [ ! -f "${2}" ] ; then
        echo "ERROR: Fastq file/s ${2} not found." >&2
 		exit 1
fi

if [ -z "$3" ] ; then
	paired=0
else 
	paired=1
fi

if [ $paired == 1 ] && [ ! -f "${3}" ] ; then
	echo "ERROR: Fastq file ${3} not found." >&2
	exit 1
fi

# Get read/s accession number from fastq filename and create output folder

read_accession=$(basename $2 .fastq | cut -d_ -f1)
mkdir ./mapping/${read_accession} 

## Index reference sequence

echo "Indexing reference genome $1 ..."

bwa-mem2 index -p ref_index ./rawdata/reference_genomes/${1}.fa
mv ref_index.* ./mapping/${read_accession}

## Mapping reads 

# Single-end reads

if [ $paired == 0 ] ; then
	echo "Mapping single-end reads..."
	bwa-mem2 mem ./mapping/${read_accession}/ref_index ${2} > ./mapping/${read_accession}/${read_accession}_bwa.sam
fi

# Paired-end reads

if [ $paired == 1 ] ; then
	echo "Mapping paired-end reads..."
	bwa-mem2 mem ./mapping/${read_accession}/ref_index ${2} ${3} > ./mapping/${read_accession}/${read_accession}_bwa.sam
fi
