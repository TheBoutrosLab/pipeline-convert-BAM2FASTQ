/**
* Fail if input BAM/CRAM contains no paired-end reads
*/
process check_PairedEnd_SAMtools {
    container params.docker_image_samtools

    ext containerOptions: {
        if (META.containsKey('reference_fasta')) {
            def reference_dir = file(META.reference_fasta).parent
            return "${params.container_mount_flag} \"${reference_dir}:${reference_dir}\""
        }
        return ''
    }

    input:
        val(META)
        tuple val(sample_id), path(sample), path(sample_index)

    output:
        val(sample_id), emit: paired_end_confirmed

    script:
    reference_arg = META.containsKey('reference_fasta') ? "--input-fmt-option reference=${META.reference_fasta}" : ''
    """
    set -o pipefail

    count_reads() {
        awk -F '\\t' '
            \$3 == "primary"              { primary = \$1 + \$2 }
            \$3 == "paired in sequencing" { paired = \$1 + \$2 }
            END { printf("%.0f %.0f\\n", primary, paired) }
        '
    }

    # Any paired-end read among the first records is enough to proceed
    read_counts=\$(samtools head ${reference_arg} -n 100000 "${sample}" | samtools flagstat -O tsv - | count_reads)
    read primary paired <<< "\$read_counts"

    # None sampled; scan the full file before failing
    if [ "\$paired" -eq 0 ]
    then
        read_counts=\$(samtools flagstat ${reference_arg} -@ ${task.cpus} -O tsv "${sample}" | count_reads)
        read primary paired <<< "\$read_counts"
    fi

    if [ "\$paired" -eq 0 ]
    then
        echo "ERROR: No paired-end reads found in ${sample} (\$primary primary reads). This pipeline requires paired-end reads." >&2
        exit 1
    fi
    """
}
