/**
* Generate statistics from BAM
*/
process calculate_readcount_BAM {
    container params.docker_image_samtools

    input:
        val(META)
        path(flagstats)

    output:
        env read_count_BAM, emit: bam_read_count

    script:
    """
    read_count_BAM=\$(awk 'BEGIN { count=0 } /read1\$|read2\$/ { count=count+\$1; if ("false"=="${params.filter_qc_failed_reads}") { count=count+\$3 } } END { printf("%.0f", count) }' $flagstats)
    """
}
