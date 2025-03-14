include { GET_GFF_STATS } from '../modules/get_gff_stats'
include { FILTER_ISOFORM } from '../modules/filter_isoform'
include { KEEP_LONG_GENE } from '../modules/keep_long_gene'
include { SELECT_BASIC_STRUCTURE } from '../modules/select_basic_structure'
include { GET_GFF_STATS_LONG } from '../modules/get_gff_stats'
include { GFFCOMPARE } from '../modules/gffcompare'

workflow GFFCOMPARE {
    take:
        input_gff

    main:
        GET_GFF_STATS(input_gff)
        FILTER_ISOFORM(input_gff)
        KEEP_LONG_GENE(FILTER_ISOFORM.out)
        SELECT_BASIC_STRUCTURE(KEEP_LONG_GENE.out)
        GET_GFF_STATS_LONG(SELECT_BASIC_STRUCTURE.out)
        GFFCOMPARE(SELECT_BASIC_STRUCTURE.out, SELECT_BASIC_STRUCTURE.out.collect())

    emit:
        gff_stats = GET_GFF_STATS.out
        gff_stats_long = GET_GFF_STATS_LONG.out
        gffcompare_results = GFFCOMPARE.out
}
