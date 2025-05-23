include { GET_GFF_STATS } from '../modules/get_gff_stats/main.nf'
include { FILTER_ISOFORM } from '../modules/filter_isoform/main.nf'
include { KEEP_LONG_GENE } from '../modules/keep_long_gene/main.nf'
include { KEEP_SHORT_GENE } from '../modules/keep_short_gene/main.nf'
include { KEEP_INTERVAL_GENE } from '../modules/keep_interval_gene/main.nf'
include { SELECT_BASIC_STRUCTURE } from '../modules/select_basic_structure/main.nf'
include { GET_GFF_STATS_LONG } from '../modules/get_gff_stats_long/main.nf'
include { GFFCOMPARE } from '../modules/gffcompare/main.nf'

workflow STRUCTURE_ANALYSIS {
    take:
        input_gff

    main:
        GET_GFF_STATS(input_gff)
        FILTER_ISOFORM(input_gff)
        //KEEP_LONG_GENE(FILTER_ISOFORM.out)
        //SELECT_BASIC_STRUCTURE(KEEP_LONG_GENE.out)
        SELECT_BASIC_STRUCTURE(FILTER_ISOFORM.out)
        GET_GFF_STATS_LONG(SELECT_BASIC_STRUCTURE.out)

        // make every pairs of gff and exclude self pairs
        ch_structure_pairs = SELECT_BASIC_STRUCTURE.out 
                        .combine(SELECT_BASIC_STRUCTURE.out)
                        .filter{it[0]!=it[1]}
        GFFCOMPARE(ch_structure_pairs)

    emit:
        gff_stats = GET_GFF_STATS.out
        gff_stats_long = GET_GFF_STATS_LONG.out
        gffcompare_results = GFFCOMPARE.out
}
