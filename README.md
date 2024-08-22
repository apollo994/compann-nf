# compann-nf
A nextflow pipelane to compare and evaluate annotations of a genome assemly

#### DESCRIPTION
A genome assembly is the starting material of most genomics analayses. To navigate and interpret the informations stored in the sequence, a genome annotatio is needed and a multitude of methods is available to generate such descriptions. Those methods, can be divided in four categories:
- *ab initio*
- protein similarity
- mRNA mapping
- genome projection

Usually, a genome annotation combines results from more than one methos and the gene models are stored in [.gff3](https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md) or [.gtf](http://mblab.wustl.edu/GTF22.html), they are similar, but mind the [differencies](https://www.biobam.com/differences-between-gtf-and-gff-files-in-genomic-data-analysis/).

`compann-nf` automates the task of evaluating the quality of a genome annotation according to a diverse set of metrics. It is based on the nextflow technology to orchestarte and parallelize processes, while reproducibility is ensured by running each process inside a Docker (or Singularity) container. 
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
git checkout dev

# run test
nextflow run main.nf \
    --gff_folder test/input \
    --outputFolder test/output \
    --ref $(realpath test/ref/Arabidopsis_lyrata.v.1.0.dna.chromosome.8.fa) \
    --lineage eudicots_odb10
```

The test takes ~5 minutes to run on an M3 chip.   
The reference must be passed as absolute path, I'm working to fix this. 


