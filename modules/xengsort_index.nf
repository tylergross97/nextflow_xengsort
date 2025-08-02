process XENGSORT_INDEX {
    container "community.wave.seqera.io/library/xengsort:2.0.9--527a5e709251280d"
    publishDir params.outdir_xengsort, mode: 'copy'

    input:
    path human_fasta
    path mouse_fasta

    output:
    path "xengsort_index.*", emit: index_files

    script:
    """
    xengsort index \\
        --index xengsort_index \\
        --host ${mouse_fasta} \\
        --graft ${human_fasta} \\
        -n 4500000000 \\
        -k 25
     """
}
