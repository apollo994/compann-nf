process SEGMENT_ANNOTATION{

    cache 'lenient'
	label 'agat'

	input:
	tuple path(gff),
          path(ext_stats),
          path(raw_data),
          path(mini_stats),
          val(from),
          val(to)

    output:
	tuple path("${gff.baseName}_from${from}_to${to}.gff3"),
          // val(from) , val(to),
          val("from${from}_to${to}")

	script:
    """
    
    gene_len=${raw_data}/with_isoforms/mrnaClass_gene.tsv


    awk -F'\t' -v min=${from} -v max=${to} '\$2 > min && \$2 < max { print \$1 }' \$gene_len > genes_from${from}_to${to}.tsv

    if [ -s genes_from${from}_to${to}.tsv ]; then
        agat_sp_filter_feature_from_keep_list.pl --gff ${gff} \\
                                                 --keep_list genes_from${from}_to${to}.tsv \\
                                                 -o ${gff.baseName}_from${from}_to${to}.gff3
    else
        echo "No genes found in range ${from} to ${to}" > /dev/stderr
        touch ${gff.baseName}_from${from}_to${to}.gff3
    fi
    """
}
