include { AGGREGATE_GFF } from '../modules/aggregate_gff/main.nf'
include { AGGREGATE_BUSCO } from '../modules/aggregate_busco/main.nf'
include { AGGREGATE_STATS } from '../modules/aggregate_stats/main.nf'

workflow RESULTS_AGGREGATION {
    take:
        gff_ministats
        gffcompare_results
        busco_results

    main:
        AGGREGATE_STATS(gff_ministats.collect())
        AGGREGATE_GFF(gffcompare_results.groupTuple(by: 1))
        AGGREGATE_BUSCO(busco_results.collect())
}
