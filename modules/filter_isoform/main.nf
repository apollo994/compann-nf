

process FILTER_ISOFORM{
    
    cache 'lenient'
    label 'agat'
    
    memory { 4.GB * task.attempt }
    errorStrategy { task.exitStatus == 140 ? 'retry' : 'terminate' }
	
    input:
	path gff

	output:
	path "${gff.baseName}_longisoforms.gff3"

	script:
	"""
	
    cut -f 3 ${gff} | sort | uniq -c

    agat_sp_keep_longest_isoform.pl -gff ${gff} -o ${gff.baseName}_longisoforms.gff3
    cut -f 3 ${gff.baseName}_longisoforms.gff3 | sort | uniq -c # This is for debugging purpose 
    """
}
