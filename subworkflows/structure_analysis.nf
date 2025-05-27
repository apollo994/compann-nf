include { GFFCOMPARE } from '../modules/gffcompare/main.nf'

workflow STRUCTURE_ANALYSIS {
    take:
        input_gff
        gff_segments

    main:
        
        gff_pairs = input_gff
                        .combine(input_gff)
                        .filter{it[0]!=it[1]}
                        .combine(channel.of("ALL"))
        
        gff_pairs_seg = gff_segments
            //.groupTuple(by: 3)
            //.flatMap { filesBag, froms, tos, label ->
            .groupTuple(by: 1)
            .flatMap { filesBag, label ->
        
                def files = filesBag as List               // still need a list here
        
                def out = []
                for (int i = 0; i < files.size(); i++) {       // all ordered pairs
                    for (int j = 0; j < files.size(); j++) {
                        if (i != j)
                            out << tuple( files[i], files[j], label )
                    }
                }
                out                                           // flatMap flattens
            }
        
        all_and_segments = gff_pairs.concat(gff_pairs_seg)
        GFFCOMPARE(all_and_segments)

    emit:
        gffcompare_results = GFFCOMPARE.out
}
