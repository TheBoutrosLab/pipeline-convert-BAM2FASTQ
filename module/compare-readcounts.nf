/**
*   Compare read counts between BAM and FASTQ
*/
process compare_readcounts {
    publishDir path: "${META.output_dir}/QC/${task.process.split(':')[-1].replace('_', '-')}",
        mode: "copy",
        pattern: "read_count_comparison.txt"

    debug true

    input:
        val(META)
        val(read_count_BAM)
        val(read_count_FASTQ)

    output:
        path("read_count_comparison.txt")

    exec:
        def read_count_BAM_long = read_count_BAM as Long
        def read_count_FASTQ_long = read_count_FASTQ as Long
        writer = file("${task.workDir}/read_count_comparison.txt")
        writer.write("file\tread_count\n")
        writer.append("BAM/CRAM\t${read_count_BAM_long}\n")
        writer.append("FASTQ(s)\t${read_count_FASTQ_long}\n")
        if ( read_count_BAM_long != read_count_FASTQ_long ) {
            System.out.println("WARNING: Read counts in input BAM/CRAM and output FASTQ(s) do not match!")
            System.out.println("WARNING: See ${META.output_dir}/QC/${task.process.split(':')[-1].replace('_', '-')}/read_count_comparison.txt for details.")
        }
}
