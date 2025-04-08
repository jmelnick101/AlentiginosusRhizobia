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
## Obtain a reference strain of Sinorhizobium meliloti to use as an outgroup
```
phylophlan_get_reference -g s__Sinorhizobium_meliloti -o SMeliloti -n 1
```
Reference strains were also obtained in this way for Mesorhizobium muleiense, M. temperatum, M. mediterraneum, M. wenxiniae, M. opportunistum, and M. alhagi. M. camelthorni and M. onobrychidis were manually downloaded because Phylophlan couldn't recognize those taxonomic labels. Additional genomes were manually downloaded for Mesorhizobium sp000503055, Mesorhizobium sp003952365, Mesorhizobium sp004020315, Mesorhizobium sp004020365, Mesorhizobium sp004020645, Mesorhizobium sp004962245, and Mesorhizobium sp004020105 (GCF_016756595.1).
## Run Phylophlan
```
phylophlan \
    -i allmesogenomes \
    -d phylophlan \
    --diversity low \
    -f supermatrix_aa2.cfg \
    --nproc 4 \
    --force_nucleotides \
    --genome_extension '.fa'
```
Flag explanations: 
Input folder, default phylophlan database, strains should be very closely related due to sharing a genus, used custom configuration file, used 4 processors, made it so I could use nucleotides for the sequence, and genome files were .fa instead of .fna (the isolate genomes originally had the .fasta extension and the reference strain originally was .fna, so those were renamed to .fa to match the metagenomes). 

## Bootstrapping

```
/home/grillo/miniconda3/envs/phylophlan/bin/raxmlHPC-PTHREADS-SSE3 -f a -x 12345 -p 1989 -# 100 -m GTRCAT -T 2 -w /home/grillo/JoshuaPhylophlan/allmesogenomes_phylophlan/boot -s allmesogenomes_concatenated.aln -n allmesogenomes_boot.tre
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

# ANI clusters
Average nucleotide identity (ANI) is used to determine bacterial species with a threshold of 95%. The tool ANIclustermap uses fastANI to calculate ANI values of the samples and display them as a heatmap. 
```
ANIclustermap -i genomesanddownloads/ -o ANIoutput --fig_width 15 --fig_height 15 --overwrite --cmap_ranges 80,85,88,90,92,93,94,95,98,100
```
`-i` is the input folder, `-o` is the output folder.

`--fig_width` and `fig_height` change the width and height from the default values of 10 to help fit the large sample number. 

`--overwrite` overwrites the previous run of the program if you need to try it multiple times. 

`--cmap_ranges` makes the heatmap display fixed colors at ANIs of each of those values instead of the usual gradient. This was chosen because there were too many samples to display the actual numbers with `--annotate`, but the gradient was not quantitative enough.

# Population structure analysis
## Rhizobia genetic distance X host genetic distance
Rather than use host genetic data directly, we can get a sense of whether closely related rhizobia match to closely related hosts by labeling the phylogeny by the variety of Astragalus lentiginosus each rhizobium sample came from. 

This was performed in FigTree. It requires no direct code as it was performed in a GUI. 

## Rhizobia genetic distance X geographic distance
(Note: since soils and seeds were taken from the same plants, the geographic distance is the same for both the rhizobia and their hosts.)

A Mantel test compares 2 distance matrices to test their correlation. To determine whether closely related bacteria are more likely to be found near each other, genetic distance was compared to geographic distance. (The same kind of test could be used to compare the genetic distance of the rhizobia to the genetic distance of their hosts for a more quantitative answer to the previous question.)

This was tested in R using 2 different packages to compare their conclusions: the `mantel.test` function of "ape" and the `mantel.rtest` function of "ade4". Note that the former takes the data as matrices while the latter takes dist objects. 

Make sure that your input matrices are in the same order and have the same names for each entry. For some reason, the geographic distance matrix produced by GeographicDistanceMatrixGenerator listed 43U_bin.1 and 43U_bin.2 as having a distance of NaN instead of 0.00, so that had to be manually edited. 

See the file `makeMantel.R`.

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
Symbiosis genes are known to frequently undergo horizontal gene transfer, and are often transmitted together. We can make tangegrams to visualize how the phylogeny of the symbiosis genes may differ from the overall phylogeny. 
## Extraction

Symbiosis genes were occasionaly missing from annotations, so they were extracted directly from the metagenomes by annotating them with Kofamscan. The code for that can be found at https://github.com/jpod1010/nodule_metagenomics. 

Genes were located in Kofamscan and matched to proteins using the code in the getGene.py file on this repository. 

I excluded 19-73C due to it containing a mix of Rhizobium and Mesorhizobium, 19-9A because it was Sinorhizobium, 19-39C due to being low quality, the old runs of 19-77J, and 19-41A due to it not detecting nifH even though it detected nodA and nodB. I also later removed the "19" from all names.

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

Make sure there aren't any duplicate names in the alignment or else the program won't run.

## Construct a tanglegram
The R package "ape" was used to read the trees and to create the figure. See the file `makeTanglegram.R`.
