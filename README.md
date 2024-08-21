# compann-nf
A nextflow pipelane to compare and evaluate genome annotations

### DEPENDENCIES

Make sure Docker and Nextflow are installed in your computer
  - [Docker](https://docs.docker.com/engine/install/), tested on `Docker version 24.0.7, build afdd53b`
  - [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation), tested on `nextflow version 23.10.1.5891` with `openjdk 21.0.4 2024-07-16` 

### Test Run


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

