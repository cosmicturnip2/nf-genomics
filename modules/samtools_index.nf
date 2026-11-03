#!/usr/bin/env nextflow

/*
 * Generate BAM index file
 */
process SAMTOOLS_INDEX {

    container 'community.wave.seqera.io/library/samtools:1.20--b5dfbd93de237464'

    input:
    path bam_path

    output:
    tuple path(bam_path), path("${bam_path}.bai")

    script:
    """
    samtools index '${bam_path}'
    """
}
