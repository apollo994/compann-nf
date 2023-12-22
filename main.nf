#!/usr/bin/env nextflow

nextflow.enable.dsl=2


// Define the output folder for the final results
params.outputFolder = "./output_results"


workflow {

	def input_gff = Channel.fromPath(params.gff_folder + '/*.{gff,gff3}')
	
	// get general stats
	GET_GFF_STATS(input_gff, params.ref)

	// prepare gff for comparison
	FILTER_ISOFORM(input_gff)
	SELECT_CDS(FILTER_ISOFORM.out)
	KEEP_LONG_GENE(SELECT_CDS.out)
	GFFCOMPARE(KEEP_LONG_GENE.out, KEEP_LONG_GENE.out.collect())
//	GFFCOMPARE.out.view()



	// run BUSCO
	EXTRACT_SEQ(input_gff, params.ref)
	RUN_BUSCO(EXTRACT_SEQ.out, params.lineage)

	// aggregate results
//  AGGREGATE_STATS()
//	AGGREGATE_GFF(GFFCOMPARE.out.collect())
//	AGGREGATE_BUSCO(RUN_BUSCO.out.collect())
}


process GET_GFF_STATS{

	publishDir params.outputFolder

	input:
	path gff
	val ref
	
	output:
	path "agat_stat/${gff.baseName}_agat_stat.txt"

	script:
	"""
	mkdir -p agat_stat
	singularity run ~/images/agat-1.2.0--pl5321hdfd78af_0.simg agat_sq_stat_basic.pl -i ${gff} -g ${ref} -o agat_stat/${gff.baseName}_agat_stat.txt
	"""


}


process FILTER_ISOFORM{

	input:
	path gff

	output:
	path "${gff.baseName}_longisoforms.gff3"

	script:
	"""
	singularity run ~/images/agat-1.2.0--pl5321hdfd78af_0.simg agat_sp_keep_longest_isoform.pl -gff ${gff}  -o ${gff.baseName}_longisoforms.gff3
	"""
}

process SELECT_CDS{
	
	input:
	path gff

	output:
	path "${gff.baseName}_CDS.gff3"

	script:
	"""
	awk '\$3 == "CDS"' ${gff} > ${gff.baseName}_CDS.gff3
	"""



}

process KEEP_LONG_GENE{
	
	
	input:
	path gff

	output:
	path "${gff.baseName}_200plus.gff3"

	script:
	"""
	singularity run ~/images/agat-1.2.0--pl5321hdfd78af_0.simg agat_sp_filter_gene_by_length.pl -gff ${gff} --size 200 --test ">" -o  ${gff.baseName}_200plus.gff3
	"""	


}





process GFFCOMPARE{
	
	publishDir params.outputFolder	

	input:
	path ref
	val test
	
	output:
	path "gffcompare_stats/${ref.baseName}.stats"	
	
	script:
	"""
	~/software/gffcompare/gffcompare -T -r ${ref} ${test.join(' ')} -o ${ref.baseName}
	mkdir gffcompare_stats
	cp ${ref.baseName}.stats gffcompare_stats

	"""	

}





process EXTRACT_SEQ{
	
	input:
	path gff
	val ref

	output:
	path "${gff.baseName}_CDS.fa"

	script:
	"""
	singularity run /nfs/users/rg/fzanarello/images/agat-1.2.0--pl5321hdfd78af_0.simg agat_sp_extract_sequences.pl -f ${ref} -g ${gff} -t cds -p -o ${gff.baseName}_CDS.fa
	"""

}



process	RUN_BUSCO{

	publishDir params.outputFolder

	input:
	path prot
	val lineage

	output:
	path "BUSCO_res/short_summary.specific.${lineage}.${prot.baseName}_BUSCO.json"
	
	script:
	"""
	singularity run /nfs/users/rg/fzanarello/images/busco-v5.5.0_cv1.simg busco -m protein -i ${prot} -l ${lineage} -o ${prot.baseName}_BUSCO
	mkdir BUSCO_res
	mv ${prot.baseName}_BUSCO/short_summary.specific.${lineage}.${prot.baseName}_BUSCO.json BUSCO_res
	"""

}

/*

process AGGREGATE_GFF{
     
	 publishDir params.outFolder
	 
	 input:
	 gffs
	 out_label

	 output:
	 path "aggregated_"





}


AGGREGATE_GFF(GFFCOMPARE.out)                                                                                                                                                                             
  1     AGGREGATE_BUSCO(RUN_BUSCO.out)



*/








