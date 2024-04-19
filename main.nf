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
	RUN_BUSCO(EXTRACT_SEQ.out, params.lineage)

	// aggregate results
//  AGGREGATE_STATS()
	AGGREGATE_GFF(GFFCOMPARE.out.collect())
//	AGGREGATE_BUSCO(RUN_BUSCO.out.collect())

}


process GET_GFF_STATS{

	publishDir params.outputFolder , mode: 'copy'

    cache 'lenient'

	input:
	path gff
	
	output:
	path "agat_stat/${gff.baseName}_agat_stat.txt"

	script:
	"""
	mkdir -p agat_stat
	singularity run ~/images/agat-1.2.0--pl5321hdfd78af_0.simg \
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
    
    memory { 4.GB * task.attempt }
    errorStrategy { task.exitStatus == 140 ? 'retry' : 'terminate' }
	
    input:
	path gff

	output:
	path "${gff.baseName}_longisoforms.gff3"

	script:
	"""
	singularity run ~/images/agat-1.2.0--pl5321hdfd78af_0.simg \
        agat_sp_keep_longest_isoform.pl \
        -gff ${gff} -o ${gff.baseName}_longisoforms.gff3
	"""
}

process KEEP_LONG_GENE{
	
    cache 'lenient'

    memory { 4.GB * task.attempt }
    errorStrategy { task.exitStatus == 140 ? 'retry' : 'terminate' }
	
	input:
	path gff

	output:
	path "${gff.baseName}_200plus.gff3"

	script:
	"""
	singularity run ~/images/agat-1.2.0--pl5321hdfd78af_0.simg \
        agat_sp_filter_gene_by_length.pl -gff ${gff} \
        --size 200 --test ">" -o  ${gff.baseName}_200plus.gff3
	"""	


}


process GFFCOMPARE{
    
    cache 'lenient'

	publishDir params.outputFolder	, mode: 'copy'

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

	input:
	path gff
	path ref

	output:
	path "${gff.baseName}_CDS.fa"

	script:
	"""
	singularity run /nfs/users/rg/fzanarello/images/agat-1.2.0--pl5321hdfd78af_0.simg \
        agat_sp_extract_sequences.pl \
        -f ${ref} \
        -g ${gff} \
        -t CDS \
        -p \
        -o ${gff.baseName}_CDS.fa
	"""

}



process	RUN_BUSCO{

    cache 'lenient'
    cpus 4

    publishDir params.outputFolder , mode: 'copy'

	input:
	path prot
	val lineage

	output:
	path "BUSCO_res/short_summary.specific.${lineage}.${prot.baseName}_BUSCO.json"
	
	script:
	"""

	singularity run /nfs/users/rg/fzanarello/images/busco-v5.5.0_cv1.simg busco \
        -m protein \
        -i ${prot} \
        -l ${lineage} \
        --download_path ${baseDir}/busco_downloads \
        --offline \
        --cpu 4 \
        -o ${prot.baseName}_BUSCO

	mkdir BUSCO_res
	
    mv ${prot.baseName}_BUSCO/short_summary.specific.${lineage}.${prot.baseName}_BUSCO.json BUSCO_res
	"""

}

