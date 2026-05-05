/**
* Convert CRAM to BAM
*/
process convert_CRAM2BAM_SAMtools {
    container params.docker_image_samtools

    publishDir path: "${META.output_dir}/intermediate/${task.process.split(':')[-1].replace('_', '-')}",
        enabled: params.save_intermediate_files,
        pattern: "*.bam",
        mode: 'copy'

    input:
        val(META)
        tuple val(sample_id), path(sample), path(sample_index)
        path(reference_fasta)

    output:
        tuple val(sample_id), path("cram2bam_${sample.baseName}.bam"), emit: bam

    script:
    """
    samtools view \
        -b \
        --threads ${task.cpus} \
        -T ${reference_fasta} \
        -o "cram2bam_${sample.baseName}.bam" \
        "${sample}"
    """
}
