#!/bin/bash

# This script processes SAM files with the following steps:
		# 1. Convert to BAM 
		# 2. Sort BAM file
		# 3. Remove duplicate reads
		# 4. Index BAM file
		# 5. Generate report using Qualimap

# Arguments required:
        # 1. SAM file

# Error catching

if [ -z "$1" ] ; then
        echo "ERROR: Insufficient arguments given, please provide: 1. a valid SAM file" >&2
		exit 1
fi

## 1. Converting to BAM file

filename=${1%.sam}
samtools view -bS ${1} > $filename.bam

## 2. Sorting BAM file

samtools sort $filename.bam -o $filename.sorted

## 3. Remove duplicate reads (e.g. from PCR)

samtools rmdup $filename.sorted $filename.sorted.rmdup

## 4. Index BAM file

samtools index $filename.sorted.rmdup
echo "Index file created: $filename.sorted.bam.rmdup.bai"

## 5. Generate report using Qualimap

/mnt/lustre/RDS-live/thomas/tools/qualimap_v2.2.1/qualimap bamqc -bam $filename.sorted.rmdup -outformat html
echo "Report can be found in location: $filename.sorted_stats/qualimapReport.html"



