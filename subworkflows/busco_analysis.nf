include { EXTRACT_SEQ } from '../modules/extract_seq/main.nf'
include { DW_BUSCO_LINEAGE } from '../modules/dw_busco_lineage/main.nf'
include { RUN_BUSCO } from '../modules/run_busco/main.nf'

workflow BUSCO_ANALYSIS {
    take:
        input_gff
        ref
        lineage

    main:
        EXTRACT_SEQ(input_gff, ref)
        DW_BUSCO_LINEAGE(lineage)
        RUN_BUSCO(EXTRACT_SEQ.out, DW_BUSCO_LINEAGE.out)

    emit:
        busco_results = RUN_BUSCO.out
}
