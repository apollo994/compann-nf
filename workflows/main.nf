include { SETUP } from '../subworkflows/setup.nf'
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

        STRUCTURE_ANALYSIS(input_gff)

        BUSCO_ANALYSIS(input_gff, ref, lineage)

        RESULTS_AGGREGATION(
            STRUCTURE_ANALYSIS.out.gffcompare_results,
            BUSCO_ANALYSIS.out.busco_results,
            STRUCTURE_ANALYSIS.out.gff_stats,
            STRUCTURE_ANALYSIS.out.gff_stats_long
        )

    emit:
        aggregated_gff = RESULTS_AGGREGATION.out.aggregated_gff
        aggregated_busco = RESULTS_AGGREGATION.out.aggregated_busco
        aggregated_stats = RESULTS_AGGREGATION.out.aggregated_stats
}
