include { AGGREGATE_GFF } from '../modules/aggregate_gff'
include { AGGREGATE_BUSCO } from '../modules/aggregate_busco'
include { AGGREGATE_STATS } from '../modules/aggregate_stats'

workflow RESULTS_AGGREGATION {
    take:
        gffcompare_results
        busco_results
        gff_stats
        gff_stats_long

    main:
        AGGREGATE_GFF(gffcompare_results.collect())
        AGGREGATE_BUSCO(busco_results.collect())
        AGGREGATE_STATS(gff_stats.collect(), gff_stats_long.collect())

    emit:
        aggregated_gff = AGGREGATE_GFF.out
        aggregated_busco = AGGREGATE_BUSCO.out
        aggregated_stats = AGGREGATE_STATS.out
}
