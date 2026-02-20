# XengSort Pipeline Testing Guide

This document describes the available test profiles and how to use them for validating the XengSort pipeline.

## Available Test Profiles

### 1. `test` - Quick Local Testing
**Purpose**: Fast validation with minimal data  
**Data Size**: ~100-200KB per sample  
**Expected Runtime**: 2-5 minutes  
**Resources**: 2-4 CPUs, 4-12 GB RAM

```bash
nextflow run main.nf -profile test,docker
```

**Data Location**: `test/data/`
- Small paired-end FASTQ files (R1/R2)
- Tiny reference genomes (100 sequences each)
- Local samplesheet

**Best For**:
- Quick syntax validation
- Testing process logic
- Development iterations
- CI/CD pipelines

---

### 2. `test_s3` - Cloud-Native Testing with Fusion
**Purpose**: Test direct S3 access without data staging  
**Data Size**: Same as `test` profile (~100-200KB)  
**Expected Runtime**: 2-5 minutes  
**Resources**: 2-4 CPUs, 4-12 GB RAM

```bash
nextflow run main.nf -profile test_s3,docker \
    -with-wave \
    -with-fusion
```

**Data Location**: Direct S3 paths
- **Samplesheet**: `s3://seqera-showcase/xengsort-test/samplesheet_s3.csv`
- **FASTQ files**: `s3://nf-core-awsmegatests/rnaseq/input_data/` (nf-core test data)
- **Human reference**: `s3://ngi-igenomes/igenomes/Homo_sapiens/NCBI/GRCh38/Sequence/WholeGenomeFasta/genome.fa`
- **Mouse reference**: `s3://ngi-igenomes/igenomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/genome.fa`

**Best For**:
- Testing Fusion file system integration
- Validating S3 credential handling
- Cloud platform development
- Testing Wave container delivery

**Requirements**:
- AWS credentials configured
- Access to public S3 buckets (nf-core, ngi-igenomes, seqera-showcase)
- Fusion file system enabled

---

### 3. `test_full` - Production-Scale Testing
**Purpose**: Full validation with realistic WES data  
**Data Size**: 2-5 GB per sample  
**Expected Runtime**: 2-4 hours  
**Resources**: 8 CPUs, 16-32 GB RAM

```bash
nextflow run main.nf -profile test_full,docker
```

**Data Requirements**:
- Create directory: `test_full/data/full/`
- Add WES FASTQ files
- Create samplesheet: `test_full/data/full/samplesheet.csv`

**Reference Genomes**: Uses iGenomes by default
- **Human (GRCh38)**: `s3://ngi-igenomes/igenomes/Homo_sapiens/NCBI/GRCh38/Sequence/WholeGenomeFasta/genome.fa`
- **Mouse (mm10)**: `s3://ngi-igenomes/igenomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/genome.fa`

**Samplesheet Format**:
```csv
sample,fastq_1,fastq_2
PDX_sample1,/path/to/PDX_sample1_R1.fastq.gz,/path/to/PDX_sample1_R2.fastq.gz
PDX_sample2,/path/to/PDX_sample2_R1.fastq.gz,/path/to/PDX_sample2_R2.fastq.gz
```

**Best For**:
- Pre-deployment validation
- Performance benchmarking
- Resource optimization
- Publication-quality results

---

## Profile Configuration Details

### Resource Allocation

| Profile | Process | CPUs | Memory | Time |
|---------|---------|------|--------|------|
| **test** | FASTP | 2 | 4 GB | 30m |
| | XENGSORT_INDEX | 4 | 12 GB | 1h |
| | XENGSORT_CLASSIFY | 4 | 12 GB | 2h |
| | MULTIQC | 1 | 2 GB | 15m |
| **test_s3** | FASTP | 2 | 4 GB | - |
| | XENGSORT_INDEX | 4 | 12 GB | - |
| | XENGSORT_CLASSIFY | 4 | 12 GB | - |
| | MULTIQC | 2 | 4 GB | - |
| **test_full** | FASTP | 8 | 16 GB | 4h |
| | XENGSORT_INDEX | 8 | 32 GB | 2h |
| | XENGSORT_CLASSIFY | 8 | 32 GB | 6h |
| | MULTIQC | 2 | 4 GB | 30m |

### Output Directories

Each profile writes to separate output directories:

```
results_test/
├── references/     # Indexed reference genomes
├── fastp/          # QC reports and trimmed reads
├── xengsort/       # Classification results
└── multiqc/        # Aggregated QC report

results_test_s3/    # Same structure for test_s3 profile
results_test_full/  # Same structure for test_full profile
```

---

## Running on Seqera Platform

### Quick Test (2-5 minutes)
```bash
tw launch https://github.com/your-org/xengsort_pipeline \
    --profile test,docker \
    --compute-env your_compute_env \
    --work-dir s3://your-bucket/work
```

### S3 Test with Fusion (2-5 minutes)
```bash
tw launch https://github.com/your-org/xengsort_pipeline \
    --profile test_s3,docker \
    --compute-env your_compute_env \
    --work-dir s3://your-bucket/work \
    --wave \
    --fusion
```

### Full Production Test (2-4 hours)
```bash
tw launch https://github.com/your-org/xengsort_pipeline \
    --profile test_full,docker \
    --compute-env your_compute_env \
    --work-dir s3://your-bucket/work \
    --params-file test_full/params.yaml
```

**Custom parameters file** (`test_full/params.yaml`):
```yaml
input: '/path/to/your/samplesheet.csv'
hg38_fasta: 's3://ngi-igenomes/igenomes/Homo_sapiens/NCBI/GRCh38/Sequence/WholeGenomeFasta/genome.fa'
nsg_fasta: 's3://ngi-igenomes/igenomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/genome.fa'
outdir_base: 's3://your-bucket/results'
```

---

## Validation Checklist

### After Running Any Test Profile:

1. **Process Completion**
   - [ ] All processes completed successfully
   - [ ] No failed tasks in workflow report
   - [ ] Exit status: 0

2. **Output Files Generated**
   - [ ] `fastp/` - QC reports and trimmed FASTQ files
   - [ ] `xengsort/` - Classification results (human/mouse/ambiguous/both)
   - [ ] `multiqc/` - Aggregated QC report
   - [ ] `references/` - Indexed genome files

3. **Quality Metrics** (check MultiQC report)
   - [ ] Read quality scores > Q30 for majority of bases
   - [ ] Adapter content < 5%
   - [ ] Classification rates reasonable for data type
   - [ ] No unexpected spikes in error rates

4. **Resource Usage** (check workflow execution report)
   - [ ] Peak memory < allocated memory
   - [ ] CPU utilization > 80%
   - [ ] No excessive task retries
   - [ ] Runtime within expected range

5. **Cloud-Specific (test_s3 profile)**
   - [ ] Fusion file system mounted successfully
   - [ ] No staging delays observed
   - [ ] S3 credentials valid throughout run
   - [ ] Wave containers pulled without errors

---

## Troubleshooting

### Common Issues

**Problem**: `test` profile fails with "file not found"  
**Solution**: Ensure test data exists in `test/data/` directory

**Problem**: `test_s3` profile fails with S3 access errors  
**Solution**: Check AWS credentials and bucket permissions

**Problem**: `test_full` profile runs out of memory  
**Solution**: Increase memory allocation in config or use larger instance

**Problem**: XengSort index creation fails  
**Solution**: Verify reference genome FASTA files are valid and not corrupted

**Problem**: Fusion mount errors with `test_s3`  
**Solution**: Enable Fusion with `--with-fusion` flag and verify Wave is active

### Getting Help

- Check workflow execution logs
- Review process-specific logs with `nextflow log`
- Inspect MultiQC report for quality issues
- Review Seqera Platform execution timeline

---

## Best Practices

1. **Always start with `test` profile** for new deployments
2. **Use `test_s3` profile** to validate cloud infrastructure before production
3. **Run `test_full` profile** before processing real patient samples
4. **Monitor resource usage** and adjust allocations based on actual data
5. **Keep test data small** (<1GB) for rapid iteration
6. **Document any profile customizations** for your specific environment
7. **Enable Fusion** for production cloud deployments to eliminate staging overhead

---

## Profile Comparison Summary

| Feature | test | test_s3 | test_full |
|---------|------|---------|-----------|
| **Data Size** | ~100KB | ~100KB | 2-5 GB |
| **Runtime** | 2-5 min | 2-5 min | 2-4 hrs |
| **Cloud Native** | ❌ | ✅ | Optional |
| **Fusion Required** | ❌ | ✅ | ❌ |
| **Local Data** | ✅ | ❌ | ✅ |
| **S3 Direct Access** | ❌ | ✅ | ❌ |
| **Production Scale** | ❌ | ❌ | ✅ |
| **Best Use Case** | Development | Cloud Testing | Pre-Production |

---

*For more information, see the main README.md or contact the pipeline maintainers.*
