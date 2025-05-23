process SELECT_BASIC_STRUCTURE{

    // This process is to keep only basic feature of the gene
    // such as gene, mRNA and exon
    // This might cause problem when mRNA is labeled as transcript
    
    cache 'lenient'

	input:
	path gff

	output:
	path "${gff.baseName}_basicelements.gff3"


	script:
	"""
	awk '\$3 == "gene" || \$3 == "mRNA" || \$3 == "exon" || \$3 == "CDS"' ${gff} > ${gff.baseName}_basicelements.gff3
    cut -f 3 ${gff.baseName}_basicelements.gff3 | sort | uniq -c # This is for debugging purpose
    """
}
