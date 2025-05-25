
process GET_GFF_MINISTATS{
	
    publishDir params.outputFolder , mode: 'copy'

    cache 'lenient'
	label 'agat'

	input:
    tuple path(gff) ,val(from), val(to), val(segment)
    path ref    

	output:
    path("summary_stat/mini/from${from}_to${to}/${gff.baseName}_ministast.tsv")
	
    script:
	"""
    mkdir -p summary_stat/mini/from${from}_to${to}

    #agat_sp_keep_longest_isoform.pl --gff ${gff} \
    #                       -o ${gff.baseName}_longest_isoform.gff
    
    bash extract_features.sh  \
            ${gff} \
            ${ref} \
            > summary_stat/mini/from${from}_to${to}/${gff.baseName}_ministast.tsv 

	"""

}

