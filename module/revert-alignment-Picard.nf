/**
* Revert alignment into separate read group BAMs
*/
process revert_alignment_Picard {
    container params.docker_image_picard

    publishDir path: "${META.output_dir}/intermediate/${task.process.split(':')[-1].replace('_', '-')}",
        pattern: "*.bam",
        enabled: params.save_intermediate_files,
        mode: "copy"

    input:
        val(META)
        tuple val(sample_id), path(sample)

    output:
        path("*.bam"), emit: read_group_bams
        val(sample_id), emit: sample_id

    script:
    """
    mkdir JAVATMP

    java -jar /opt/conda/envs/picard/share/picard-slim-${params.picard_version}-0/picard.jar RevertSam \
        --INPUT "${sample}" \
        --OUTPUT ./ \
        --OUTPUT_BY_READGROUP true \
        --SORT_ORDER unsorted \
        --TMP_DIR JAVATMP \
        --RESTORE_ORIGINAL_QUALITIES true \
        --VALIDATION_STRINGENCY LENIENT

    rm -rf JAVATMP
    """
}
