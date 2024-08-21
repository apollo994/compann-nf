#!/usr/bin/env nextflow

nextflow.enable.dsl=2


// Define the output folder for the final results
params.outputFolder = "./output_results"


workflow {

	def input_gff = Channel.fromPath(params.gff_folder + '/*.{gff,gff3}')
	
	// get general stats
	GET_GFF_STATS(input_gff)

	// run gff compare on genes containing CDS and with an 
    // exon chain longer than >200bp
    input_gff.view()
	SELECT_CDS(input_gff)
    FILTER_ISOFORM(SELECT_CDS.out)
	KEEP_LONG_GENE(FILTER_ISOFORM.out)
	GFFCOMPARE(KEEP_LONG_GENE.out, KEEP_LONG_GENE.out.collect())

	// run BUSCO
	EXTRACT_SEQ(input_gff, params.ref)
    DW_BUSCO_LINEAGE(params.lineage)
	RUN_BUSCO(EXTRACT_SEQ.out, DW_BUSCO_LINEAGE.out)


	// aggregate results
	AGGREGATE_GFF(GFFCOMPARE.out.collect())
	AGGREGATE_BUSCO(RUN_BUSCO.out.collect())
//  AGGREGATE_STATS()



}


process GET_GFF_STATS{
    
	
    publishDir params.outputFolder , mode: 'copy'

    cache 'lenient'
	label 'agat'

	input:
	path gff
	
	output:
	path "agat_stat/${gff.baseName}_agat_stat.txt"

	script:
	"""
	mkdir -p agat_stat
	agat_sq_stat_basic.pl -i ${gff} -o agat_stat/${gff.baseName}_agat_stat.txt
	"""


}


process SELECT_CDS{
    
    cache 'lenient'

	input:
	path gff

	output:
	path "${gff.baseName}_CDS.gff3"


	script:
	"""
	awk '\$3 == "CDS" || \$3 == "gene" || \$3 == "mRNA" || \$3 == "exon"' ${gff} > ${gff.baseName}_CDS.gff3
	"""
}


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
	agat_sp_keep_longest_isoform.pl -gff ${gff} -o ${gff.baseName}_longisoforms.gff3
	"""
}

process KEEP_LONG_GENE{
	
    cache 'lenient'
    label 'agat'

    memory { 4.GB * task.attempt }
    errorStrategy { task.exitStatus == 140 ? 'retry' : 'terminate' }
	
	input:
	path gff

	output:
	path "${gff.baseName}_200plus.gff3"

	script:
	"""
    agat_sp_filter_gene_by_length.pl -gff ${gff} --size 200 --test ">" -o  ${gff.baseName}_200plus.gff3
	"""	


}


process GFFCOMPARE{
    
    cache 'lenient'
    label 'gffcompare'

	publishDir params.outputFolder	, mode: 'copy'

	input:
	path ref
	val test
	
	output:
	path "gffcompare_stats/${ref.baseName}.stats"	
    //path "gffcompare_stats/test"

	script:
	"""
	gffcompare -T -r ${ref} ${test.join(' ')} -o ${ref.baseName}
	mkdir gffcompare_stats
	cp ${ref.baseName}.stats gffcompare_stats
    
    which gffcompare > test
    cp test gffcompare_stats


	"""	

}

process AGGREGATE_GFF{
    
    cache 'lenient'

    publishDir params.outputFolder , mode: 'copy'

    input:
    val gff_stats
    
    output:
	path "gffcompare_summary/*"
    
    script:
    """
    mkdir gffcompare_summary
    python ${baseDir}/scripts/aggregate_gffcompare.py \
        --gffcompare ${gff_stats.join(' ')} \
        --out_label gffcompare_summary/combined_gffcompare
    """

}


process EXTRACT_SEQ{
	
    cache 'lenient'
    label 'agat'

	input:
	path gff
	path ref

	output:
	path "${gff.baseName}_CDS.fa"

	script:
	"""
    agat_sp_extract_sequences.pl \
        -f ${ref} \
        -g ${gff} \
        -t CDS \
        -p \
        -o ${gff.baseName}_CDS.fa
	"""

}

process DW_BUSCO_LINEAGE {
    
    cache 'lenient'
    label 'busco'

    input:
    val lineage

    output:
    path "dw_lineage/lineages/${lineage}" 

    script:
    """
    mkdir dw_lineage
    busco --download_path dw_lineage --download ${lineage}
    """

}



process	RUN_BUSCO{

    cache 'lenient'
    label 'busco'
    cpus 4

    publishDir params.outputFolder , mode: 'copy'

	input:
	path prot
	val lineage

	output:
	path "BUSCO_res/short_summary.specific.${lineage.baseName}.BUSCO_${prot}.json"
	
	script:
	"""

	busco \
        -m protein \
        -i ${prot} \
        -l ${lineage} \
        --offline \
        --cpu 4 \
        -o BUSCO_${prot}

	mkdir BUSCO_res
	
    mv BUSCO_${prot}/short_summary.specific.${lineage.baseName}.BUSCO_${prot}.json BUSCO_res
	"""

}


process AGGREGATE_BUSCO{
    
    cache 'lenient'

    publishDir params.outputFolder , mode: 'copy'

    input:
    val BUSCO_stats
    
    output:
	path "BUSCO_summary/*"
    
    script:
    """
    mkdir BUSCO_summary
    python ${baseDir}/scripts/aggregate_BUSCO.py \
        --busco ${BUSCO_stats.join(' ')} \
        --out BUSCO_summary/combined_BUSCO_results.csv
    """

}
