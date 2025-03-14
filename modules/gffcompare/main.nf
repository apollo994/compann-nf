
process GFFCOMPARE{
    
    cache 'lenient'
    label 'gffcompare'

	publishDir params.outputFolder	, mode: 'copy'

	input:
	path ref
	val test
	
	output:
	path "gffcompare/all_samples/${ref.baseName}.stats"	

	script:
	"""
    echo ${ref} ${test} > samples.txt
    gffcompare -T -r ${ref} ${test.join(' ')} -o ${ref.baseName}
	mkdir -p gffcompare/all_samples
	cp ${ref.baseName}.stats gffcompare/all_samples
	"""	

}
