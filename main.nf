#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Validate mandatory parameters
def validateParams() {
    def errors = []
    if (!params.input) { errors << "Missing required parameter: --input" }
    if (!params.outdir_base) { errors << "Missing required parameter: --outdir_base" }
    if (!params.hg38_fasta) { errors << "Missing required parameter: --hg38_fasta" }
    if (!params.nsg_fasta) { errors << "Missing required parameter: --nsg_fasta" }
    if (errors) {
        log.error "Parameter validation failed:"
        errors.each { log.error "  - ${it}" }
        System.exit(1)
    }
    if (!file(params.input).exists()) {
        log.error "Input samplesheet does not exist: ${params.input}"
        System.exit(1)
    }
    if (!file(params.hg38_fasta).exists()) {
        log.error "Human genome FASTA does not exist: ${params.hg38_fasta}"
        System.exit(1)
    }
    if (!file(params.nsg_fasta).exists()) {
        log.error "NSG genome FASTA does not exist: ${params.nsg_fasta}"
        System.exit(1)
    }
}

// Import modules
include { FASTP } from './modules/fastp.nf'
include { XENGSORT_INDEX } from './modules/xengsort_index.nf'
include { XENGSORT_CLASSIFY } from './modules/xengsort_classify.nf'
include { XENGSORT_SUMMARY } from './modules/xengsort_summary.nf'
include { MULTIQC } from './modules/multiqc.nf'

workflow {
    validateParams()

    ch_samplesheet = Channel
        .fromPath(params.input)
        .splitCsv(header:true)
        .map { row ->
            def meta = [ sample: row.sample ]
            def reads = [ file(row.fastq1), file(row.fastq2) ]
            tuple(meta, reads)
        }

    FASTP(ch_samplesheet)

    ch_human_fa = channel.fromPath(params.hg38_fasta)
    ch_nsg_fa  = channel.fromPath(params.nsg_fasta)

    XENGSORT_INDEX(ch_human_fa, ch_nsg_fa)
    ch_xengsort_index = XENGSORT_INDEX.out.index_files.first()

    XENGSORT_CLASSIFY(
        FASTP.out.trimmed_reads,
        ch_xengsort_index
    )

    XENGSORT_SUMMARY(
        XENGSORT_CLASSIFY.out.classification
            .map { meta, classification_file -> classification_file }
            .collect()
    )

    // Start with minimal MultiQC - just FASTP outputs
    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(FASTP.out.json_report)
    ch_multiqc_files = ch_multiqc_files.mix(FASTP.out.html_report)

    MULTIQC(
        ch_multiqc_files.collect()
    )
}
