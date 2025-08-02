process FASTP {
	container "quay.io/biocontainers/fastp:0.24.0--heae3180_1"
	publishDir params.outdir_fastp, mode: 'copy'

	input:
	tuple val(meta), path(reads)

	output:
	tuple val(meta), path("${meta.sample}_trimmed_{1,2}.fastq.gz"), emit: trimmed_reads
	path "${meta.sample}_fastp.json", emit: json_report
	path "${meta.sample}_fastp.html", emit: html_report

	script:
	"""
	fastp \
        -i ${reads[0]} \
        -I ${reads[1]} \
        -o ${meta.sample}_trimmed_1.fastq.gz \
        -O ${meta.sample}_trimmed_2.fastq.gz \
        -j ${meta.sample}_fastp.json \
        -h ${meta.sample}_fastp.html
	"""
}
