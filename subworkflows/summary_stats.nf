include { GET_GFF_STATS_EXTENDED } from '../modules/get_gff_stats_extended/main.nf'
include { SEGMENT_ANNOTATION } from '../modules/segment_annotation/main.nf'
include { GET_GFF_MINISTATS } from '../modules/get_gff_stats_mini/main.nf'

workflow SUMMARY_STATS {
    take:
        input_gff
        ref

    main:
        GET_GFF_STATS_EXTENDED(input_gff, ref)
        
        segments = Channel.of(
            [0, 200],
            [200, 500],
            [500, 1000],
            [1000, 5000],
            [5000, 10000000]
            )
        segment_input = GET_GFF_STATS_EXTENDED.out.combine(segments)

        SEGMENT_ANNOTATION(segment_input)
        GET_GFF_MINISTATS(SEGMENT_ANNOTATION.out, ref)

        // collect ministats frol all generated in GET_GFF_STATS_EXTENDED
        all_ministats = GET_GFF_STATS_EXTENDED.out
                              .map({it[3]})
                              .concat(GET_GFF_MINISTATS.out)

    emit:
        gff_extended_stats = GET_GFF_STATS_EXTENDED.out
        gff_mini_stats = all_ministats
        gff_segments = SEGMENT_ANNOTATION.out 

}
