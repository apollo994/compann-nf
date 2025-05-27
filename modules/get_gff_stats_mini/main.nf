
process GET_GFF_MINISTATS{
	
    publishDir params.outputFolder , mode: 'copy'

    cache 'lenient'
	label 'agat'

	input:
    //tuple path(gff) ,val(from), val(to), val(segment)
    tuple path(gff), val(segment)
    path ref    

	output:
    path("summary_stat/mini/${segment}/${gff.baseName}_ministast.tsv")
	
    script:
	"""
    mkdir -p summary_stat/mini/${segment}

    bash extract_features.sh  \
            ${gff} \
            ${ref} \
            > summary_stat/mini/${segment}/${gff.baseName}_ministast.tsv 

	"""

}

