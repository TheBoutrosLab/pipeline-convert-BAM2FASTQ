include { generate_standard_filename } from "../external/pipeline-Nextflow-module/modules/common/generate_standardized_filename/main.nf"

/**
* Generate FASTQ from BAM
*/
process generate_FASTQ_SAMtools {
    container params.docker_image_samtools

    publishDir path: "${META.output_dir}/output/${LB}",
        pattern: "*.fastq.gz",
        mode: "copy"

    ext log_dir_suffix: { "-${LB}-${read_group}" }

    input:
        val(META)
        tuple val(read_group), val(LB), path(sample)

    output:
        tuple val(LB), path("*.fastq.gz"), emit: fastq

    script:
    prefix = generate_standard_filename(
        "SAMtools-${params.samtools_version}",
        params.dataset_id,
        params.sample.id,
        ['additional_information': "${read_group}_${params.portion_id}"]
    )
    """
    if [ ${params.split_unmapped_reads_to_separate_file} == true ]
    then
        samtools fastq \
            -t \
            --threads ${task.cpus} \
            -c 1 \
            -1 "${prefix}-R1.fastq.gz" \
            -2 "${prefix}-R2.fastq.gz" \
            -s "${prefix}-singleton.fastq.gz" \
            -0 "${prefix}-other.fastq.gz" \
            "${sample}"
    else
        samtools fastq \
            -t \
            --threads ${task.cpus} \
            -c 1 \
            -1 "${prefix}-R1.fastq.gz" \
            -2 "${prefix}-R2.fastq.gz" \
            "${sample}"
    fi
    """
}
