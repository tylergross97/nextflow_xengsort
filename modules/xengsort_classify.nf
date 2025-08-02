process XENGSORT_CLASSIFY {
    memory { 32.GB * task.attempt }  // Start with 32GB, doubles on retry
    cpus 4
    
    errorStrategy { task.exitStatus in 137..141 ? 'retry' : 'terminate' }
    maxRetries 3

    container "community.wave.seqera.io/library/htslib_xengsort:eac4b0e9210e6e01"
    publishDir params.outdir_xengsort, mode: 'copy'

    input:
    tuple val(meta), path(reads)
    path index_files

    output:
    tuple val(meta), path("${meta.sample}.xengsort.txt"), emit: classification
    tuple val(meta), path("${meta.sample}-host.*.fq.gz"), emit: host_reads, optional: true
    tuple val(meta), path("${meta.sample}-graft.*.fq.gz"), emit: graft_reads, optional: true
    tuple val(meta), path("${meta.sample}-both.*.fq.gz"), emit: both_reads, optional: true
    tuple val(meta), path("${meta.sample}-neither.*.fq.gz"), emit: neither_reads, optional: true
    tuple val(meta), path("${meta.sample}-ambiguous.*.fq.gz"), emit: ambiguous_reads, optional: true    
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.sample}"
    def paired = reads instanceof List && reads.size() == 2 ? "--pairs ${reads[1]}" : ""

    """
    # Find the index prefix from the index files
    INDEX_PREFIX=\$(find . -name "*.hash" | head -1 | sed 's/\\.hash\$//')
    
    xengsort classify \\
        --index \$INDEX_PREFIX \\
        --fastq ${reads[0]} \\
        $paired \\
	--mode count \\
        --prefix ${prefix} \\
	--compression gz \\
        $args > ${prefix}.xengsort.txt
    """

}
