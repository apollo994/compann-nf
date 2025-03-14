#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.outputFolder = "./output_results"
params.gff_folder = "./gff_files"
params.ref = "./reference.fa"
params.lineage = "eukaryota_odb10"

include { MAIN_WORKFLOW } from './workflows/main'

workflow {
    def input_gff = Channel.fromPath(params.gff_folder + '/*.{gff,gff3}')
    input_gff.view()

    MAIN_WORKFLOW(input_gff, params.ref)
}
