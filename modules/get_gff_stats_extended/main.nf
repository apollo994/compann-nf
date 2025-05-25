
process GET_GFF_STATS_EXTENDED{
    
	
    publishDir params.outputFolder , mode: 'copy'

    cache 'lenient'
	label 'agat'

	input:
	path gff
    path ref
	
	output:
    tuple path("${gff.baseName}_longest_isoform.gff"),
          path("summary_stat/extended/${gff.baseName}_agat_extended.txt"),
          path("summary_stat/extended/${gff.baseName}_agat_extended.txt_raw_data")
	
    script:
	"""
    mkdir -p summary_stat/extended
    agat_sp_add_introns.pl --gff ${gff} \
                           -o ${gff.baseName}_with_introns.gff
    
    agat_sp_statistics.pl -i ${gff.baseName}_with_introns.gff \
                          -r \
                          -g ${ref} \
                          -o summary_stat/extended/${gff.baseName}_agat_extended.txt
    
    agat_sp_keep_longest_isoform.pl --gff ${gff.baseName}_with_introns.gff \
                           -o ${gff.baseName}_longest_isoform.gff
	"""

}

