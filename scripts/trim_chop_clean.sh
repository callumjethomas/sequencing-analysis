#!/bin/bash

# Trim reads using fastp and porechopper, then generate fastqc/multiqc
# Arguments required:
	# 1. an accession number
	# 2. minimum Phred score
	# 3. minimum length
	# 4. Nanopore reads?

# Error catching

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] ; then
	echo "ERROR: Insufficient arguments given, please provide: 1. accession number, 2. minimum Phred score, 3. minimum length, 4. if reads are Nanopore reads (y/n)." >&2
	exit 1
fi

number_regex='^[0-9]+$'

if ! [[ $2 =~ $number_regex ]] || ! [[ $3 =~ $number_regex ]]; then
	echo "ERROR: Phred score and minimum length must be given as integers" >&2
	exit 1
fi

if [ $4 != "y" ] && [ $4 != "n" ] ; then
	echo "ERROR: Must specify if reads are Nanopore reads (y) or not (n)." >&2
	exit 1
fi

if [ ! -d "./rawdata/${1}" ] ; then
	echo "ERROR: No fastq files found for that accession number in directory ./rawdata/${1}." >&2
	exit 1
fi

# Remove overrepresented sequences using fastp

echo "Running fastp trimming on $1"
echo "Phred score threshold: $2"
echo "Minimum length: ${3}bp"

# If reads are paired:
#
#if [ -f "./rawdata/${1}/${1}_1.fastq" ] && [ -f "./rawdata/${1}/${1}_2.fastq" ]; then
#	echo "Processing paired reads..."
#	/mnt/lustre/RDS-live/downing/FASTQC/fastp -i ./rawdata/${1}/${1}_1.fastq -I ./rawdata/${1}/${1}_2.fastq -o ./cleandata/${1}/${1}_1_trim.fastq -O ./cleandata/${1}/${1}_2_trim.fastq -q $2 -l $3 -h ./analyses/${1}/${1}_trim.html -p

# Else if reads are single:

#else
	echo "Processing single reads..."
	/mnt/lustre/RDS-live/downing/FASTQC/fastp -i ./rawdata/${1}/${1}.fastq -o ./cleandata/${1}/${1}_trim.fastq -q $2 -l $3 -h ./analyses/${1}/${1}_trim.html -p
#fi

# Clean up unneeded json file

echo "Removing unneeded files..."
rm fastp.json

# Run Porechop if the sequences are from Nanopore sequencing, otherwise skip

if [ $4 = "y" ]; then
	echo "Removing Nanopore adapters with Porechop..."
	
	FILES=./cleandata/${1}/${1}*_trim.fastq

	for file in $FILES; do
		echo "Chopping $file..."
		/mnt/lustre/RDS-live/downing/Porechop/porechop-runner.py -i $file -o ./cleandata/${1}/$(basename ${file%.*})_chop.fastq --verbosity 1 > ./logs/${1}/$(basename ${file%.*})_chop.txt
		done
fi
echo "Nanopore adapter removal complete."

# Generate fastqc and multiqc files

echo "Generating FastQC files..." 
fastqc ./cleandata/${1}/*.fastq -o ./analyses/${1}
multiqc ./analyses/${1}/* -ip -f -o ./analyses/${1}
echo "Read trimming complete."
