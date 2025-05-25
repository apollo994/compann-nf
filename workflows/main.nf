include { SETUP } from '../subworkflows/setup.nf'
include { SUMMARY_STATS } from '../subworkflows/summary_stats.nf'
include { STRUCTURE_ANALYSIS } from '../subworkflows/structure_analysis.nf'
include { BUSCO_ANALYSIS } from '../subworkflows/busco_analysis.nf'
include { RESULTS_AGGREGATION } from '../subworkflows/results_aggregation.nf'

workflow MAIN_WORKFLOW {
    take:
        input_gff
        ref
        lineage

    main:
        SETUP()

        SUMMARY_STATS(input_gff, ref)

        STRUCTURE_ANALYSIS(input_gff, SUMMARY_STATS.out.gff_segments)

        BUSCO_ANALYSIS(input_gff, ref, lineage)

        RESULTS_AGGREGATION(
            STRUCTURE_ANALYSIS.out.gffcompare_results,
            BUSCO_ANALYSIS.out.busco_results,
        )

}
