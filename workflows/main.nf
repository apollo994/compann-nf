include { SETUP } from '../subworkflows/setup'
include { GFFCOMPARE } from '../subworkflows/gffcompare'
include { BUSCO_ANALYSIS } from '../subworkflows/busco_analysis'
include { RESULTS_AGGREGATION } from '../subworkflows/results_aggregation'

workflow MAIN_WORKFLOW {
    take:
        input_gff
        ref
        lineage

    main:
        SETUP()

        GFFCOMPARE(input_gff)

        BUSCO_ANALYSIS(input_gff, ref, lineage)

        RESULTS_AGGREGATION(
            GFFCOMPARE.out.gffcompare_results,
            BUSCO_ANALYSIS.out.busco_results,
            GFFCOMPARE.out.gff_stats,
            GFFCOMPARE.out.gff_stats_long
        )

    emit:
        aggregated_gff = RESULTS_AGGREGATION.out.aggregated_gff
        aggregated_busco = RESULTS_AGGREGATION.out.aggregated_busco
        aggregated_stats = RESULTS_AGGREGATION.out.aggregated_stats
}
