
process GFFCOMPARE{
    
    cache 'lenient'
    label 'gffcompare'

	publishDir params.outputFolder	, mode: 'copy'

	input:
    tuple path(ref), path(test), val(segment)
	
	output:
	tuple path("gffcompare/${segment}/${ref.baseName}_VS_${test.baseName}.stats"),
          val(segment)

	script:
	"""
    gffcompare -T -r ${ref} ${test}
	mkdir -p gffcompare/${segment}
    mv gffcmp.stats gffcompare/${segment}/${ref.baseName}_VS_${test.baseName}.stats
	"""	

}
