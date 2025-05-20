
process GFFCOMPARE{
    
    cache 'lenient'
    label 'gffcompare'

	publishDir params.outputFolder	, mode: 'copy'

	input:
	// path ref
	// val test
    tuple path(ref), path(test)
	
	output:
	path "gffcompare/all_samples/${ref.baseName}_VS_${test.baseName}.stats"	

	script:
	"""
    gffcompare -T -r ${ref} ${test}
	mkdir -p gffcompare/all_samples
    mv gffcmp.stats gffcompare/all_samples/${ref.baseName}_VS_${test.baseName}.stats
	"""	

}
