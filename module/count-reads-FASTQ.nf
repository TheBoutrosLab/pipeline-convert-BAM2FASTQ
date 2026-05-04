include { sanitize_string } from '../external/pipeline-Nextflow-module/modules/common/generate_standardized_filename/main.nf'

/**
* Calculate total read count in FASTQ file
*/
process count_reads_FASTQ {
    container params.docker_image_samtools

    ext log_dir_suffix: { "-${sanitize_string(fastq_id)}" }

    input:
        val(META)
        tuple val(fastq_id), path(fastq)

    output:
        env read_count_FASTQ, emit: read_count

    script:
    """
    read_count_FASTQ=\$(((\$(zcat ${fastq} | wc -l) / 4)))
    """
}
