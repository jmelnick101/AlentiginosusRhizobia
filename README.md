# AlentiginosusRhizobia
Code to work with genomes for the rhizobia associated with Astragalus lentiginosus.

# Assembly, binning, and taxonomy

See https://github.com/jpod1010/nodule_metagenomics

# Phylophlan: 
## Generate a custom configuration file so that a nucleotide genome can be used with this amino acid database:
```
phylophlan_write_config_file -o supermatrix_aa2.cfg \
    -d a \
    --db_aa diamond \
    --map_dna diamond \
    --map_aa diamond \
    --msa mafft \
    --trim trimal \
    --tree1 fasttree \
    --tree2 raxml \
    --overwrite \
    --verbose \
    --force_nucleotides
```
## Run Phylophlan
```
phylophlan \
    -i mesorhizobia \
    -d phylophlan \
    --diversity low \
    -f supermatrix_aa2.cfg \
    --force_nucleotides \
    --genome_extension '.fa'
```
Flag explanations: 
Input folder, default phylophlan database, strains should be very closely related due to sharing a genus, used custom configuration file, made it so I could use nucleotides for the sequence, and genome files were .fa instead of .fasta. 

## Bootstrapping

```
/home/grillo/miniconda3/envs/phylophlan/bin/raxmlHPC-PTHREADS-SSE3 -f a -x 12345 -p 1989 -# 100 -m GTRCAT -T 2 -w /home/grillo/JoshuaPhylophlan/mesorhizobia_phylophlan/test -s mesorhizobia_concatenated.aln -n mesorhizobia_refined.tre
```
Phylophlan doesn't bootstrap by default, so I reran the alignment file it produced through RAxML. 

Flag explanations:

`-f a` tells it to run a rapid bootstrap analysis and search for best-scoring ML tree. 

`-x 12345` is the seed for the bootstrapping.

`-p 1989` is the seed for parsimony inferences. I chose the same one as in the Phylophlan configuration file. 

`-# 100` tells it to run 100 bootstraps.

`-m GTRCAT` is the nucleotide substitution model.

`-T 2` tells it to use 2 threads.

`-w` is the output directory.

`-s` is the alignment file. In this case, it is the one produced by Phylophlan.

`-n` is the output file.

# Annotation:
Two alternate tools were used. The code is very similar for both. They start in the input folder and output into the parent folder containing that folder. Most of the code is just trimming the names of the files, such as "19_30C_S380_bin.1.fa". They all start with "19_" and most of the suffixes are just from assembly; the only meaningful part is the "30C" in this example, so we trim everything after that. 

This can be accomplished prior to annotation (such as for running Phylophlan with neater names) by running
```
for i in *.fa; do x=${i%_*}; y=${x%_*}.fa; mv $i $y; done
```

This iterates through every file with the ".fa" extension. `x=${i%_*}` trims the final underscore and everything after it (in this case "_bin.1.fa"). Then take that value and trim it the same way to remove the "_S380", then add the extension back in, leaving a neat "19_30C.fa" as the final file name. If you want to test this before actually changing the file names, replace `mv $i $y` with `echo $y` to simply print out a list of what the updated names would look like. If you are working with a format other than ".fa", either replace both instances of ".fa" with a different extension like ".fasta" or just omit the extension to iterate through all files regardless of extension. 

To remove the "19_" from the beginning of the file names, the code is very similar. 
```
for i in *; do x=${i#*_}; mv $i $x; done
```

Running this on the original file would change "19_30C_S380_bin.1.fa" to "30C_S380_bin.1.fa"; running this on the shortened file "19_30C.fa" would result in "30C.fa", which Phylophlan would read as just "30C" if ".fa" was specified as the extension.

## PGAP
```
for i in *; do x=${i%_*}; y=${x%_*}; sudo ~/pgap.py -r --taxcheck -o ../$y -g ./$i -s 'Mesorhizobium'; done
```
The code for the first batch of samples was originally run without the --taxcheck flag, so I reran the pipeline with --taxcheck-only and the output directory as taxcheck_$y so that it wouldn't have to go through the full annotation process. The taxonomy check gives the ANI compared to the most closely related species, so this flag is optional. 

## Prokka
```
for i in *; do x=${i%_*}; y=${x%_*}; prokka -outdir ../$y -prefix $y ./$i; done
```

# Symbiosis genes

## Extraction

Symbiosis genes were occasionaly missing from annotations, so they were extracted directly from the metagenomes by annotating them with Kofamscan. The code for that can be found at https://github.com/jpod1010/nodule_metagenomics. 

Genes were located in Kofamscan and matched to proteins using the code in the getGene.py file on this repository. 

## Alignment

Alignments were produced with MAFFT using the following code (swapping "NifH" for "nodA" or "nodB" as appropriate):
```
"/usr/bin/mafft"  --auto --reorder "JoshuaMelnickData/metagenome_NifH.fasta" > "nifHalign.aln"
```

## Phylogenies

RAxML was called for each symbiosis gene using the same settings as we used for bootstrapping the whole phylogeny above. `-w`, `-s`, and `-n` were changed to match the gene names. For example: 
```
/home/grillo/miniconda3/envs/phylophlan/bin/raxmlHPC-PTHREADS-SSE3 -f a -x 12345 -p 1989 -# 100 -m PROTCATLG -T 2 -w /home/grillo/nifHphylo -s /home/grillo/nifHalign.aln -n nifHphylogeny.tre
```
`-m` has also been changed to fit an amino acid substitution model; I selected the one that Phylophlan would use by default for an amino acid supermatrix.
