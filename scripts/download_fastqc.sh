#!/bin/bash

# This script downloads and trims raw sequencing reads from NCBI

## Downloading data by accession from NCBI

if [ $# -eq 0 ]; then
 echo "ERROR: No accession number given."
 exit 1
fi

echo "Prefetching files to temporary directory..."

# This allows for faster download than just using fasterq-dump + accession, especially for very large files

/mnt/lustre/RDS-live/downing/sratoolkit.3.0.1-ubuntu64/bin/prefetch $1 -O ./temp

echo "Downloading reads..."

mkdir -p ./rawdata/$1 ./cleandata/$1 ./analyses/$1 ./logs/$1

/mnt/lustre/RDS-live/downing/sratoolkit.3.0.1-ubuntu64/bin/fasterq-dump ./temp/$1/$1.sra -O ./rawdata/$1 -t ./temp/$1 -f

echo "Download complete."

echo "Deleting temporary directory..."

rm -r ./temp/$1

## Perform FastQC on raw reads (single or paired)

fastqc ./rawdata/$1/$1*.fastq -o ./analyses/$1

