/**
* Filter QC failed reads from BAM
*/
process filter_BAM_SAMtools {
    container params.docker_image_samtools

    publishDir path: "${META.output_dir}/intermediate/${task.process.split(':')[-1].replace('_', '-')}",
        pattern: "*reads*",
        enabled: params.save_intermediate_files,
        mode: "copy"

    input:
        val(META)
        tuple val(sample_id), path(sample), path(sample_index)

    output:
        tuple val(sample_id), path("filtered_reads_${sample.baseName}.bam"), emit: filtered
        path("rejected_reads_${sample.baseName}.bam")

    script:
    """
    samtools view \
        -u \
        --exclude-flags 512 \
        --threads ${task.cpus} \
        --output "filtered_reads_${sample.baseName}.bam" \
        "${sample}"

    samtools view \
        -u \
        --require-flags 512 \
        --threads ${task.cpus} \
        --output "rejected_reads_${sample.baseName}.bam" \
        "${sample}"
    """
}
