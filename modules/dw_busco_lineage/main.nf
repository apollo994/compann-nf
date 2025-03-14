process DW_BUSCO_LINEAGE {
    
    cache 'lenient'
    label 'busco'

    input:
    val lineage

    output:
    path "dw_lineage/lineages/${lineage}" 

    script:
    """
    mkdir dw_lineage
    busco --download_path dw_lineage --download ${lineage}
    """

}
