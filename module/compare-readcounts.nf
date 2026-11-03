/**
*   Compare read counts between BAM and FASTQ
*/
process compare_readcounts {
    publishDir path: "${META.output_dir}/QC/${task.process.split(':')[-1].replace('_', '-')}",
        mode: "copy",
        pattern: "read_count_comparison.txt",
        failOnError: false

    debug true

    input:
        val(META)
        tuple val(read_count_BAM), val(excluded_read_count), val(primary_read_count)
        val(read_count_FASTQ)

    output:
        path("read_count_comparison.txt")

    exec:
        def read_count_BAM_long = read_count_BAM as Long
        def excluded_read_count_long = excluded_read_count as Long
        def primary_read_count_long = primary_read_count as Long
        def read_count_FASTQ_long = read_count_FASTQ as Long

        // Single-end reads are written to the "other" FASTQ when splitting is enabled
        def expected_read_count_FASTQ = read_count_BAM_long + (params.split_unmapped_reads_to_separate_file ? excluded_read_count_long : 0)

        writer = file("${task.workDir}/read_count_comparison.txt")
        writer.write("file\tread_count\n")
        writer.append("BAM/CRAM paired-end (expected)\t${read_count_BAM_long}\n")
        writer.append("BAM/CRAM single-end (excluded)\t${excluded_read_count_long}\n")
        writer.append("FASTQ(s)\t${read_count_FASTQ_long}\n")
        if ( excluded_read_count_long > 0 ) {
            def excluded_percentage = String.format('%.2f', 100 * excluded_read_count_long / primary_read_count_long)
            System.out.println("WARNING: Excluded ${excluded_read_count_long} of ${primary_read_count_long} primary reads (${excluded_percentage}%) as single-end; not included in R1/R2 FASTQs.")
        }
        if ( expected_read_count_FASTQ != read_count_FASTQ_long ) {
            System.out.println("WARNING: Read counts in input BAM/CRAM and output FASTQ(s) do not match!")
            System.out.println("WARNING: See ${META.output_dir}/QC/${task.process.split(':')[-1].replace('_', '-')}/read_count_comparison.txt for details.")
        }
}
