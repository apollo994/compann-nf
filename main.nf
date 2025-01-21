#!/usr/bin/env nextflow

nextflow.enable.dsl=2


// Define the output folder for the final results
params.outputFolder = "./output_results"


workflow {

	def input_gff = Channel.fromPath(params.gff_folder + '/*.{gff,gff3}')
    input_gff.view()
    
    // Create output structure
    MAKE_OUT_FOLDERS()

	// get general stats
	GET_GFF_STATS(input_gff)

    // run gff compare on genes with an exon chain longer than >200bp
    FILTER_ISOFORM(input_gff)
    KEEP_LONG_GENE(FILTER_ISOFORM.out)
    SELECT_BASIC_STRUCTURE(KEEP_LONG_GENE.out)
    GET_GFF_STATS_LONG(SELECT_BASIC_STRUCTURE.out)
    GFFCOMPARE(SELECT_BASIC_STRUCTURE.out, SELECT_BASIC_STRUCTURE.out.collect())



	// run BUSCO
	EXTRACT_SEQ(input_gff, params.ref)
    DW_BUSCO_LINEAGE(params.lineage)
	RUN_BUSCO(EXTRACT_SEQ.out, DW_BUSCO_LINEAGE.out)


	// aggregate results
	AGGREGATE_GFF(GFFCOMPARE.out.collect())
	AGGREGATE_BUSCO(RUN_BUSCO.out.collect())
    AGGREGATE_STATS(GET_GFF_STATS.out.collect(),GET_GFF_STATS_LONG.out.collect()) 


}

process MAKE_OUT_FOLDERS{

    publishDir params.outputFolder , mode: 'copy'
    
    output:
    path BUSCO
    path gffcompare
    path summary_stat

    script:
    """
    mkdir -p BUSCO
    mkdir -p gffcompare
    mkdir -p summary_stat
    """
}


process GET_GFF_STATS{
    
	
    publishDir params.outputFolder , mode: 'copy'

    cache 'lenient'
	label 'agat'

	input:
	path gff
	
	output:
	path "summary_stat/full/${gff.baseName}_agat_stat.txt"

	script:
	"""
    mkdir -p summary_stat/full
	agat_sq_stat_basic.pl -i ${gff} -o summary_stat/full/${gff.baseName}_agat_stat.txt
	"""


}


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
	awk '\$3 == "gene" || \$3 == "mRNA" || \$3 == "CDS"' ${gff} > ${gff.baseName}_basicelements.gff3
    cut -f 3 ${gff.baseName}_basicelements.gff3 | sort | uniq -c # This is for debugging purpose
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
	
    cut -f 3 ${gff} | sort | uniq -c

    agat_sp_keep_longest_isoform.pl -gff ${gff} -o ${gff.baseName}_longisoforms.gff3
    cut -f 3 ${gff.baseName}_longisoforms.gff3 | sort | uniq -c # This is for debugging purpose 
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


process GET_GFF_STATS_LONG{
    
	
    publishDir params.outputFolder , mode: 'copy'

    cache 'lenient'
	label 'agat'

	input:
	path gff
	
	output:
	path "summary_stat/long/${gff.baseName}_agat_stat.txt"

	script:
	"""
    mkdir -p summary_stat/long
	agat_sq_stat_basic.pl -i ${gff} -o summary_stat/long/${gff.baseName}_agat_stat.txt
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
	path "gffcompare/all_samples/${ref.baseName}.stats"	

	script:
	"""
    echo ${ref} ${test} > samples.txt
    gffcompare -T -r ${ref} ${test.join(' ')} -o ${ref.baseName}
	mkdir -p gffcompare/all_samples
	cp ${ref.baseName}.stats gffcompare/all_samples
	"""	

}

process AGGREGATE_GFF{
    
    cache 'lenient'
    label 'python'
    
    publishDir params.outputFolder , mode: 'copy'

    input:
    val gff_stats
    
    output:
	path "gffcompare/summary/*"
    
    script:
    """
    mkdir -p gffcompare/summary
    hostname     
    python ${baseDir}/bin/aggregate_gffcompare.py \
        --gffcompare ${gff_stats.join(' ')} \
        --out_label gffcompare/summary/combined_gffcompare
    """

}


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
	path transcripts
	val lineage

	output:
	path "BUSCO/all_samples/short_summary.specific.${lineage.baseName}.BUSCO_${transcripts}.json"
	
	script:
	"""
	busco \
        -m proteins \
        -i ${transcripts} \
        -l ${lineage} \
        --offline \
        --cpu 4 \
        -o BUSCO_${transcripts}

	mkdir -p BUSCO/all_samples
	
    mv BUSCO_${transcripts}/short_summary.specific.${lineage.baseName}.BUSCO_${transcripts}.json BUSCO/all_samples
	"""

}


process AGGREGATE_BUSCO{
    
    cache 'lenient'
    label 'python'

    publishDir params.outputFolder , mode: 'copy'

    input:
    val BUSCO_stats
    
    output:
	path "BUSCO/summary/combined_BUSCO_results.csv"
    
    script:
    """
    mkdir -p BUSCO/summary
    python ${baseDir}/bin/aggregate_BUSCO.py \
        --busco ${BUSCO_stats.join(' ')} \
        --out BUSCO/summary/combined_BUSCO_results.csv
    """
}

process AGGREGATE_STATS{
    
    cache 'lenient'
    label 'python'

    publishDir params.outputFolder , mode: 'copy'

    input:
    val full_stats
    val long_stats
    
    output:
	path "summary_stat/summary_stats_combined.csv"
    
    script:
    """
    mkdir -p summary_stat
    python ${baseDir}/bin/aggregate_stats.py \
        --stats ${full_stats.join(' ')} ${long_stats.join(' ')} \
        --out summary_stat/summary_stats_combined.csv
    """
}
