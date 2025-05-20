
process EXTRACT_SEQ{
	
    cache 'lenient'
    label 'agat'

	input:
	path gff
	path ref

	output:
	path "${gff.baseName}_transcripts.fa"

	script:
	"""

    agat_sp_extract_sequences.pl \
        -f ${ref} \
        -g ${gff} \
        -t CDS \
        -p \
        -o ${gff.baseName}_transcripts.fa

    """

}
