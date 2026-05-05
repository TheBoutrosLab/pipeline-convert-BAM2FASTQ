/**
* Generate statistics from BAM
*/
process generate_statistics_SAMtools {
    container params.docker_image_samtools

    publishDir path: "${META.output_dir}/QC/${task.process.split(':')[-1].replace('_', '-')}",
        pattern: "*.txt",
        mode: "copy"

    input:
        val(META)
        tuple val(sample_id), path(sample)

    output:
        path("flagstats_${sample.baseName}.txt"), emit: flagstats
        path("samstats_${sample.baseName}.txt")

    script:
    """
    samtools flagstats \
        -@ ${task.cpus} ${sample} > flagstats_${sample.baseName}.txt

    samtools stats \
        -@ ${task.cpus} ${sample} > samstats_${sample.baseName}.txt
    """
}
