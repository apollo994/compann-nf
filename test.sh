nextflow run main.nf -resume  \
    --gff_folder test/input \
    --outputFolder test/output \
    --ref $(realpath test/ref/Arabidopsis_lyrata.v.1.0.dna.chromosome.8.fa) \
    --lineage eudicots_odb10 \ 

