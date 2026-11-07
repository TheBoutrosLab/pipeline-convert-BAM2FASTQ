/**
* Calculate paired-end, excluded single-end and primary read counts from BAM flagstats
*/
process calculate_readcount_BAM {
    container params.docker_image_samtools

    input:
        val(META)
        path(flagstats)

    output:
        tuple env('read_count_BAM'), env('excluded_read_count'), env('primary_read_count'), emit: bam_read_counts

    script:
    """
    read_count_BAM=\$(awk 'BEGIN { count=0 } /read1\$|read2\$/ { count=count+\$1; if ("false"=="${params.filter_qc_failed_reads}") { count=count+\$3 } } END { printf("%.0f", count) }' $flagstats)
    primary_read_count=\$(awk 'BEGIN { count=0 } / primary\$/ { count=count+\$1; if ("false"=="${params.filter_qc_failed_reads}") { count=count+\$3 } } END { printf("%.0f", count) }' $flagstats)

    # Primary reads flagged as neither READ1 nor READ2 (single-end) are not written to R1/R2 FASTQs
    excluded_read_count=\$(( primary_read_count - read_count_BAM ))
    """
}
