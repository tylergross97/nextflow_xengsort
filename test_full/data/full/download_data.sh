#!/bin/bash

# Download PDX WES test data from NCI PDM Database
# These files represent whole exome sequencing data from PDX models

set -euo pipefail

DATA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Downloading PDX WES files to ${DATA_DIR}..."

# Sample 319-R-AH8 (R1 and R2)
echo "Downloading 319-R-AH8 R1..."
curl -L -o "${DATA_DIR}/319-R-AH8_R1.fastq.gz" \
  "https://pdmdb.cancer.gov/pdm/111316~319-R~AH8~v2.0.2.51.0~WES.R1.FASTQ.gz"

echo "Downloading 319-R-AH8 R2..."
curl -L -o "${DATA_DIR}/319-R-AH8_R2.fastq.gz" \
  "https://pdmdb.cancer.gov/pdm/111316~319-R~AH8~v2.0.2.51.0~WES.R2.FASTQ.gz"

# Sample 319-R-AH6T26 (R1 and R2)
echo "Downloading 319-R-AH6T26 R1..."
curl -L -o "${DATA_DIR}/319-R-AH6T26_R1.fastq.gz" \
  "https://pdmdb.cancer.gov/pdm/111316~319-R~AH6T26~v2.0.2.51.0~WES.R1.FASTQ.gz"

echo "Downloading 319-R-AH6T26 R2..."
curl -L -o "${DATA_DIR}/319-R-AH6T26_R2.fastq.gz" \
  "https://pdmdb.cancer.gov/pdm/111316~319-R~AH6T26~v2.0.2.51.0~WES.R2.FASTQ.gz"

echo "Download complete!"
echo ""
echo "Files downloaded:"
ls -lh "${DATA_DIR}"/*.fastq.gz

echo ""
echo "To verify downloads, check file sizes:"
echo "Expected: ~1-5 GB per file for WES data"
