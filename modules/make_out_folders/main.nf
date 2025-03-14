process MAKE_OUT_FOLDERS{

    publishDir params.outputFolder , mode: 'copy'
    
    output:
    path BUSCO
    path gffcompare
    path summary_stat

    script:
    """
    mkdir -p BUSCO
    mkdir -p gffcompare
    mkdir -p summary_stat
    """
}

