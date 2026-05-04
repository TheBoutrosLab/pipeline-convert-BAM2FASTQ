#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Include processes and workflows here
include { run_validate_PipeVal } from './external/pipeline-Nextflow-module/modules/PipeVal/validate/main.nf'
include { indexFile } from './external/pipeline-Nextflow-module/modules/common/indexFile/main.nf'

include { convert_CRAM2BAM_SAMtools } from './module/convert-CRAM2BAM-SAMtools.nf'
include { generate_statistics_SAMtools } from './module/bam-stats-SAMtools.nf'
include { calculate_readcount_BAM } from './module/calculate-readcount-BAM.nf'
include { filter_BAM_SAMtools } from './module/filter-BAM-SAMtools.nf'

log.info """\
=================================
C O N V E R T - B A M 2 F A S T Q
=================================
Boutros Lab

Current Configuration:

    - pipeline:
        name: ${workflow.manifest.name}
        version: ${workflow.manifest.version}

    - input:
        sample: ${params.sample}

    - output:
        output: ${params.output_dir}
        output_dir_base: ${params.output_dir_base}
        log_output_dir: ${params.log_output_dir}

    - options:
      save_intermediate_files = ${params.save_intermediate_files}
      filter_qc_failed_reads = ${params.filter_qc_failed_reads}
      split_unmapped_reads_to_seperate_file = ${params.split_unmapped_reads_to_seperate_file}

    Tools Used:
        tool SAMtools: ${params.docker_image_samtools}
        tool Picard: ${params.docker_image_picard}
        tool PipeVal: ${params.docker_image_pipeval}

    All parameters:
        ${params}

------------------------------------
Starting workflow...
------------------------------------
        """
        .stripIndent()

workflow {
    /**
    *   Input channel processing
    */
    Channel.from(params.sample)
        .map{ sample -> ['index': indexFile(sample.path)] + sample }
        .set{ input_ch_sample_with_index }

    input_ch_sample_with_index
        .map{ sample -> [sample.path, sample.index] }
        .flatten()
        .set{ input_ch_validate }

    base_meta = Channel.value([
        'log_output_dir': params.log_output_dir,
        'output_dir': params.output_dir_pipeline
    ])

    /**
    *   Input validation
    */
    run_validate_PipeVal(
        base_meta.combine(input_ch_validate)
    )

    run_validate_PipeVal.out.validation_result
        .collectFile(
            name: 'input_validation.txt',
            storeDir: "${params.output_dir_pipeline}/validation"
        )

    /**
    *   CRAM to BAM conversion
    */
    if (params.input_file_type == 'CRAM') {
        convert_CRAM2BAM_SAMtools(
            base_meta,
            input_ch_sample_with_index.map{ sample_info -> [sample_info.id, sample_info.path, sample_info.index] },
            params.reference_fasta
        )

        convert_CRAM2BAM_SAMtools.out.bam.set{ input_ch_bam }
    } else {
        input_ch_sample_with_index.map{ input_sample ->
            [input_sample.id, input_sample.path]
        }
        .set{ input_ch_bam }
    }

    /**
    *   Generate statistics for given BAM
    */
    generate_statistics_SAMtools(
        base_meta,
        input_ch_bam
    )

    calculate_readcount_BAM(
        base_meta,
        generate_statistics_SAMtools.out.flagstats
    )

    /**
    *   Filter QC failed reads
    */
    if (params.filter_qc_failed_reads) {
        filter_BAM_SAMtools(
            base_meta,
            input_ch_sample_with_index.map{ sample_info -> [sample_info.id, sample_info.path, sample_info.index] },
        )

        filter_BAM_SAMtools.out.filtered.set{ input_ch_revert_alignment }
    } else {
        input_ch_bam.set{ input_ch_revert_alignment }
    }
}
