# XengSort Test Profiles - Quick Reference

## Usage Commands

### Profile 1: `test` (Local Quick Test)
```bash
nextflow run main.nf -profile test,docker
```
⏱️ **Runtime**: 2-5 minutes  
💾 **Data**: ~100KB, local files  
☁️ **Cloud**: Not required  
🎯 **Use for**: Development, CI/CD, quick validation

---

### Profile 2: `test_s3` (Cloud-Native with Fusion)
```bash
nextflow run main.nf -profile test_s3,docker -with-wave -with-fusion
```
⏱️ **Runtime**: 2-5 minutes  
💾 **Data**: ~100KB, direct S3 access  
☁️ **Cloud**: Required (AWS S3)  
🎯 **Use for**: Cloud infrastructure testing, Fusion validation

**S3 Paths Used**:
- Samplesheet: `s3://seqera-showcase/xengsort-test/samplesheet_s3.csv`
- Reads: `s3://nf-core-awsmegatests/rnaseq/input_data/` (nf-core test data)
- Human ref: `s3://ngi-igenomes/.../GRCh38/.../genome.fa`
- Mouse ref: `s3://ngi-igenomes/.../mm10/.../genome.fa`

---

### Profile 3: `test_full` (Production-Scale)
```bash
nextflow run main.nf -profile test_full,docker
```
⏱️ **Runtime**: 2-4 hours  
💾 **Data**: 2-5 GB, local or S3  
☁️ **Cloud**: Optional  
🎯 **Use for**: Pre-production validation, performance benchmarking

**Setup Required**:
1. Create `test_full/data/full/` directory
2. Add WES FASTQ files (paired-end)
3. Create `samplesheet.csv` with sample paths

---

## Resource Comparison

| Metric | test | test_s3 | test_full |
|--------|------|---------|-----------|
| **CPUs** | 2-4 | 2-4 | 8 |
| **Memory (FASTP)** | 4 GB | 4 GB | 16 GB |
| **Memory (INDEX)** | 12 GB | 12 GB | 32 GB |
| **Memory (CLASSIFY)** | 12 GB | 12 GB | 32 GB |
| **Total Runtime** | 2-5 min | 2-5 min | 2-4 hrs |
| **Input Size** | 100 KB | 100 KB | 2-5 GB |
| **Fusion/Wave** | ❌ | ✅ Required | ❌ |

---

## When to Use Each Profile

### Use `test` when:
- 🔧 Developing new features
- ⚡ Testing syntax/logic changes
- 🤖 Running CI/CD pipelines
- 📝 Validating configurations locally
- 🚀 Quick iteration cycles

### Use `test_s3` when:
- ☁️ Testing cloud infrastructure
- 🔄 Validating Fusion file system
- 🔑 Checking S3 credentials
- 📦 Testing Wave container delivery
- 🌐 Deploying to cloud platforms

### Use `test_full` when:
- ✅ Pre-deployment validation
- 📊 Performance benchmarking
- ⚖️ Resource optimization
- 🔬 Testing with realistic data
- 📈 Preparing for production

---

## Output Locations

All profiles write to separate output directories to avoid conflicts:

```
.
├── results_test/           # test profile outputs
│   ├── references/
│   ├── fastp/
│   ├── xengsort/
│   └── multiqc/
├── results_test_s3/        # test_s3 profile outputs
│   └── (same structure)
└── results_test_full/      # test_full profile outputs
    └── (same structure)
```

---

## Validation Checklist

After running any profile, verify:

- [ ] ✅ All processes completed successfully
- [ ] 📄 Output files exist in expected directories
- [ ] 📊 MultiQC report generated
- [ ] 🧬 Classified reads present (human/mouse/ambiguous/both)
- [ ] 💻 Resource usage within limits
- [ ] 🚫 No failed tasks or retries

---

## Troubleshooting Quick Guide

| Error | Profile | Solution |
|-------|---------|----------|
| File not found | `test` | Ensure test data in `test/data/` |
| S3 access denied | `test_s3` | Check AWS credentials |
| Out of memory | `test_full` | Increase compute resources |
| Fusion mount error | `test_s3` | Add `--with-fusion` flag |
| Index creation fails | All | Verify reference FASTA validity |

---

## Seqera Platform Launch

### Quick Test
```bash
tw launch /path/to/pipeline \
    --profile test,docker \
    --compute-env <your_ce> \
    --work-dir s3://<bucket>/work
```

### S3 with Fusion
```bash
tw launch /path/to/pipeline \
    --profile test_s3,docker \
    --compute-env <your_ce> \
    --work-dir s3://<bucket>/work \
    --wave --fusion
```

### Full Production Test
```bash
tw launch /path/to/pipeline \
    --profile test_full,docker \
    --compute-env <your_ce> \
    --work-dir s3://<bucket>/work \
    --params-file custom_params.yaml
```

---

## Best Practices

1. ✅ Always run `test` profile first for new changes
2. ☁️ Use `test_s3` to validate cloud setup before production
3. 🏭 Run `test_full` with production-like data before launch
4. 📊 Review MultiQC reports for each test run
5. 💾 Keep test data small for rapid development
6. 🔄 Enable Fusion for production cloud deployments
7. 📝 Document customizations in params files

---

*See TESTING.md for detailed documentation and advanced configurations.*
