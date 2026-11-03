#!/usr/bin/env nextflow

// Module INCLUDE statements

include { SAMTOOLS_INDEX } from './modules/samtools_index.nf'
include { GATK_HAPLOTYPECALLER } from './modules/gatk_haplotypecaller.nf'

/*
 * Pipeline parameters
 */

params {
    // Set one of these two for either file import or folder
    bam_from_file: String = ''
    bam_from_folder: String = ''

    // Accessory files for GATK_HAPLOTYPECALLER
    reference: Path
    reference_index: Path
    reference_dict: Path
    intervals: Path
}

// Primary input

workflow {

    main:
    // Declare channel var
    def bam_path_ch

    // Input channel either from file import or folder
    if( params.bam_from_file) {
        bam_path_ch = channel.fromPath(params.bam_from_file)
            .splitCsv(header: true)
            .map { row -> file( row.reads_bam)}
    }
    else if( params.bam_from_folder) {
        bam_path_ch = channel.fromPath(params.bam_from_folder)
    }
    else {
        error("Set input either from a file import (via params.bam_from_file) or from a folder (via params.bam_from_folder)")
    }

    // Load the file paths for the accessory files (reference and intervals)
    ref_file        = file(params.reference)
    ref_index_file  = file(params.reference_index)
    ref_dict_file   = file(params.reference_dict)
    intervals_file  = file(params.intervals)

    // Create BAM index
    SAMTOOLS_INDEX(bam_path_ch)

    // Call all Variants
    GATK_HAPLOTYPECALLER(
        SAMTOOLS_INDEX.out,
        ref_file,
        ref_index_file,
        ref_dict_file,
        intervals_file
    )

    publish:
    // Declare outputs to publish
    bam_n_bai = SAMTOOLS_INDEX.out
    vcf = GATK_HAPLOTYPECALLER.out.vcf
    vcf_idx = GATK_HAPLOTYPECALLER.out.idx
}

output {
    bam_n_bai {
        path 'bam'
    }
    vcf {
        path 'vcf'
    }
    vcf_idx {
        path 'vcf'
    }
}
