#!/bin/bash

# 1. scaffold file in fasta format
# 2. reference genome (optional)
# 3. genbank file (optional)

# Error and argument checking
if [ -z "$1" ] ; then
        echo "ERROR: Insufficient arguments given, please provide a scaffold file in fasta format." >&2
        exit 1
fi

outdir=$(dirname $1 | cut -d "/" -f 2)

# Quast analysis of assemblies
 if [ -z "$2" ]; then
	echo "Evaluating output with quast, no reference genome given..."
	/mnt/lustre/RDS-live/downing/miniconda3/bin/quast $1 -o analyses/$outdir/quast

elif [ -z "$3" ]; then
	echo "Evaluating output with quast, using reference genome $2..."
	/mnt/lustre/RDS-live/downing/miniconda3/bin/quast $1 -r $2 -o analyses/$outdir/quast

else
	echo "Evaluating output with quast, using reference genome $2 and genbank record $3 ..."
	/mnt/lustre/RDS-live/downing/miniconda3/bin/quast $1 -r $2 -g $3 -o analyses/$outdir/quast
fi

echo "Evaluation complete. See analyses/$outdir/quast/report.txt for results."
