include { AGGREGATE_GFF } from '../modules/aggregate_gff/main.nf'
include { AGGREGATE_BUSCO } from '../modules/aggregate_busco/main.nf'
include { AGGREGATE_STATS } from '../modules/aggregate_stats/main.nf'

workflow RESULTS_AGGREGATION {
    take:
        gffcompare_results
        busco_results

    main:
        
       // labelALL_gffcompare = gffcompare_results
       //                         .collect()
       //                         .map{ x -> tuple(x, "ALL") }

       // grouped_segments = gffcompare_results_seg
       //                     .groupTuple(by: 1)
       // 
       // merged_gffcompare = labelALL_gffcompare.mix(grouped_segments)
        

        AGGREGATE_GFF(gffcompare_results.groupTuple(by: 1))


        AGGREGATE_BUSCO(busco_results.collect())

}
