# compann-nf
A nextflow pipeline to compare and evaluate annotations of a genome assembly

#### DESCRIPTION
A genome assembly is the starting material of most genomics analyses. To navigate and interpret the informations stored in the sequence, a genome annotatio is needed and a multitude of methods is available to generate such descriptions. Those methods, can be divided in four categories:
- *ab initio*
- protein similarity
- mRNA mapping
- genome projection

Usually, a genome annotation combines results from more than one methos and the gene models are stored in [.gff3](https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md) or [.gtf](http://mblab.wustl.edu/GTF22.html), they are similar, but mind the [differencies](https://www.biobam.com/differences-between-gtf-and-gff-files-in-genomic-data-analysis/).

`compann-nf` automates the task of evaluating the quality of a genome annotation according to a diverse set of metrics. It is based on the nextflow technology to orchestrate and parallelize processes, while reproducibility is ensured by running each process inside a Docker (or Singularity) container. 
You should consider using `compann-nf` when you want to know what annotation methods or pipeline parameter provide the most complete and accurate annotation. 

### HOW TO USE `compann-nf`

## Dependencies

Make sure Docker and Nextflow are installed in your computer
  - [Docker](https://docs.docker.com/engine/install/), tested on `Docker version 24.0.7, build afdd53b`
  - [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation), tested on `nextflow version 23.10.1.5891` with `openjdk 21.0.4 2024-07-16` 

## Test Run

If you have Docker and Nextflow installed on you system you are ready to go

```
# clone and switch to dev branch 
git clone https://github.com/apollo994/compann-nf.git
cd compann-nf

# run test
nextflow run main.nf \
    --gff_folder test/input \
    --outputFolder test/output \
    --ref $(realpath test/ref/Arabidopsis_lyrata.v.1.0.dna.chromosome.8.fa) \
    --lineage eudicots_odb10
```

The test takes ~5 minutes to run on an M3 chip.   
The reference must be passed as absolute path, I'm working to fix this. 

## Modules
#### General statistics
This module provides information about the models and their substructures.
It is run twice, (1) on the input annotation as they are and (2) after preparing them for the `GFF compare` step.
#### GFF compare
Gff compare provides accuracy (precision and recall) metrics in relation to a reference annotation. This test is performed only on gene, mRNA and exon features, all the ot  
Compann-nf is taught to work with and without reference. Each annotation is used as reference and all the others as queries, the process is repeated for all input annotation. The result is an accuracy matrix to provide an overview of the most similar annotation. When a reference is provided, this would be the most relevant comparison.     

#### BUSCO analyis
BUSCO provides a measure of completeness based on the presence/absence of genes expected in the phylogenetic group of the species in the analysis. 




