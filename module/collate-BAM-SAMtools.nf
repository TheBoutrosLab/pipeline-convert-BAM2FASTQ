/**
* Collate BAM
*/
process collate_BAM_SAMtools {
    container params.docker_image_samtools

    publishDir path: "${META.output_dir}/intermediate/${task.process.split(':')[-1].replace('_', '-')}",
        pattern: "*collated.bam",
        enabled: params.save_intermediate_files,
        mode: "copy"

    ext log_dir_suffix: { "-${read_group}" }

    input:
        val(META)
        tuple val(read_group), path(sample)

    output:
        tuple val(read_group), env(LB), path("${read_group}-collated.bam"), emit: bam
        path(sample), emit: bam_for_deletion

    script:
    """
    samtools collate \
        --threads ${task.cpus} \
        -u \
        -o "${read_group}-collated.bam" \
        "${sample}"

    LB=\$(samtools view --header-only "${read_group}-collated.bam" | grep '^@RG' | awk '/@RG/ {for(i=1;i<=NF;i++) if(\$i ~ /^LB:/){ split(\$i, a, ":"); print a[2]}}')
    """
}
