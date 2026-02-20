#!/bin/bash

# Script to generate test data for xengsort pipeline
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔧 Generating test data for xengsort pipeline..."

# Create samplesheet
echo "📝 Creating samplesheet..."
cat > samplesheet.csv << 'EOF'
sample,fastq1,fastq2
human,tests/data/xengsort/human_R1.fastq.gz,tests/data/xengsort/human_R2.fastq.gz
mouse,tests/data/xengsort/mouse_R1.fastq.gz,tests/data/xengsort/mouse_R2.fastq.gz
mixed,tests/data/xengsort/mixed_R1.fastq.gz,tests/data/xengsort/mixed_R2.fastq.gz
EOF

# Create reference genomes
echo "🧬 Creating reference genomes..."
cat > human.fa << 'EOF'
>chr1
ACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGT
TGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCA
GGGGCCCCAAAATTTTGGGGCCCCAAAATTTTGGGGCCCCAAAATTTTGGGGCCCCAAAATTTT
>chr2
ATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCG
CGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGATCGAT
EOF

cat > mouse.fa << 'EOF'
>chr1
TTTTAAAACCCCGGGGTTTTAAAACCCCGGGGTTTTAAAACCCCGGGGTTTTAAAACCCCGGGG
GGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAA
CCCCGGGGAAAATTTTCCCCGGGGAAAATTTTCCCCGGGGAAAATTTTCCCCGGGGAAAATTTT
>chr2
AAAAGGGGCCCCTTTTAAAAGGGGCCCCTTTTAAAAGGGGCCCCTTTTAAAAGGGGCCCCTTTT
TTTTCCCCGGGGAAAATTTTCCCCGGGGAAAATTTTCCCCGGGGAAAATTTTCCCCGGGGAAAA
EOF

# Create FASTQ files and compress them
echo "📊 Creating FASTQ files..."

# Function to create FASTQ file
create_fastq() {
    local filename=$1
    local reads=("${@:2}")
    
    > "$filename"
    for i in "${!reads[@]}"; do
        read_num=$((i + 1))
        echo "@read${read_num}" >> "$filename"
        echo "${reads[i]}" >> "$filename"
        echo "+" >> "$filename"
        echo "$(printf 'I%.0s' $(seq 1 ${#reads[i]}))" >> "$filename"
    done
}

# Human samples
human_reads=(
    "ACGTACGTACGTACGTACGTACGTACGTACGT"
    "TGCATGCATGCATGCATGCATGCATGCATGCA"
    "GGGGCCCCAAAATTTTGGGGCCCCAAAATTTT"
)

create_fastq "human_R1.fastq" "${human_reads[@]}"
create_fastq "human_R2.fastq" "${human_reads[@]}"

# Mouse samples
mouse_reads=(
    "TTTTAAAACCCCGGGGTTTTAAAACCCCGGGG"
    "GGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAA"
    "CCCCGGGGAAAATTTTCCCCGGGGAAAATTTT"
)

create_fastq "mouse_R1.fastq" "${mouse_reads[@]}"
create_fastq "mouse_R2.fastq" "${mouse_reads[@]}"

# Mixed samples
mixed_reads=(
    "ACGTACGTACGTACGTACGTACGTACGTACGT"
    "TTTTAAAACCCCGGGGTTTTAAAACCCCGGGG"
    "GGGGCCCCAAAATTTTGGGGCCCCAAAATTTT"
    "CCCCGGGGAAAATTTTCCCCGGGGAAAATTTT"
)

create_fastq "mixed_R1.fastq" "${mixed_reads[@]}"
create_fastq "mixed_R2.fastq" "${mixed_reads[@]}"

# Compress FASTQ files
echo "🗜️  Compressing FASTQ files..."
gzip *.fastq

# Create mock index files
echo "📇 Creating mock index files..."
touch xengsort_index.hash
touch xengsort_index.kmer
echo "minimal index for testing" > xengsort_index.info

# Create mock classification files
echo "📈 Creating mock classification files..."
cat > human.xengsort.txt << 'EOF'
prefix	host	graft	ambiguous	both	neither
human	100	800	50	25	25
EOF

cat > mouse.xengsort.txt << 'EOF'
prefix	host	graft	ambiguous	both	neither
mouse	900	50	30	10	10
EOF

cat > mixed.xengsort.txt << 'EOF'
prefix	host	graft	ambiguous	both	neither
mixed	400	400	100	50	50
EOF

echo "✅ Test data generation complete!"
echo "📁 Files created in: $SCRIPT_DIR"
ls -la
