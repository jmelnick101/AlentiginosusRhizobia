# AlentiginosusRhizobia
Code to work with genomes for the rhizobia associated with _Astragalus lentiginosus_.

# Assembly, binning, and taxonomy

See https://github.com/jpod1010/nodule_metagenomics

# PhyloPhlAn: 
To download PhyloPhlAn, go to https://github.com/biobakery/phylophlan
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
The settings are the same as the default `supermatrix_aa.cfg` file Phylophlan would produce except for the `--force_nucleotides` flag.
## Obtain a reference strain of Sinorhizobium meliloti to use as an outgroup
```
phylophlan_get_reference -g s__Sinorhizobium_meliloti -o SMeliloti -n 1
```
Reference strains were also obtained in this way for _Bradyrhizobium japonicum_, _Mesorhizobium muleiense_, _M. temperatum_, _M. mediterraneum_, _M. wenxiniae_, _M. opportunistum_, and _M. alhagi_. _M. camelthorni_ and _M. onobrychidis_ were manually downloaded because Phylophlan couldn't recognize those taxonomic labels. Additional genomes were manually downloaded for _Mesorhizobium sp000503055_, _Mesorhizobium sp003952365_, _Mesorhizobium sp004020315_, _Mesorhizobium sp004020365_, _Mesorhizobium sp004020645_, _Mesorhizobium sp004962245_, _Mesorhizobium sp004020105_ (GCF_016756595.1), and _Mesorhizobium spAaZ16_ (GCF_043769475.1).
## Run PhyloPhlAn
```
phylophlan \
    -i allmesogenomes \
    -d phylophlan \
    --diversity low \
    -f supermatrix_aa2.cfg \
    --nproc 16 \
    --force_nucleotides \
    --genome_extension '.fa'
```
Flag explanations: 
Input folder, default phylophlan database, strains should be very closely related due to sharing a genus, used custom configuration file, used 16 processors, made it so I could use nucleotides for the sequence, and genome files were .fa instead of .fna (the isolate genomes originally had the .fasta extension and the reference strain originally was .fna, so those were renamed to .fa to match the metagenomes). 

## Bootstrapping

```
/home/grillo/miniconda3/envs/phylophlan/bin/raxmlHPC-PTHREADS-SSE3 -f a -x 12345 -p 1989 -# 100 -m GTRCAT -T 2 -w /home/grillo/JoshuaPhylophlan/allmesogenomes_phylophlan/boot -s allmesogenomes_concatenated.aln -n allmesogenomes_boot.tre
```
PhyloPhlAn doesn't bootstrap by default, so I reran the alignment file it produced through RAxML. 

Flag explanations:

`-f a` tells it to run a rapid bootstrap analysis and search for best-scoring ML tree. 

`-x 12345` is the seed for the bootstrapping.

`-p 1989` is the seed for parsimony inferences. I chose the same one as in the Phylophlan configuration file. 

`-# 100` tells it to run 100 bootstraps.

`-m GTRCAT` is the nucleotide substitution model.

`-T 2` tells it to use 2 threads.

`-w` is the output directory. Note that this has to be an absolute path, and it can't make the folder itself.

`-s` is the alignment file. In this case, it is the one produced by Phylophlan.

`-n` is the output file.

# ANI clusters
Average nucleotide identity (ANI) is used to determine bacterial species with a threshold of 95%. The tool [ANIclustermap](https://github.com/moshi4/ANIclustermap) uses fastANI to calculate ANI values of the samples and display them as a heatmap. 
```
ANIclustermap -i genomesanddownloads/ -o ANIoutput --fig_width 15 --fig_height 15 --overwrite --cmap_ranges 80,85,88,90,92,93,94,95,98,100
```
`-i` is the input folder, `-o` is the output folder.

`--fig_width` and `fig_height` change the width and height from the default values of 10 to help fit the large sample number. 

`--overwrite` overwrites the previous run of the program if you need to try it multiple times. 

`--cmap_ranges` makes the heatmap display fixed colors at ANIs of each of those values instead of the usual gradient. This was chosen because there were too many samples to display the actual numbers with `--annotate`, but the gradient was not quantitative enough.

# Population structure analysis
## Rhizobia genetic distance X host genetic distance
Rather than use host genetic data directly, we can get a sense of whether closely related rhizobia match to closely related hosts by labeling the phylogeny by the variety of _Astragalus lentiginosus_ each rhizobium sample came from. 

This was performed in [FigTree](https://tree.bio.ed.ac.uk/software/figtree/). It requires no direct code as it was performed in a GUI. I imported annotations from the file `treeannotationsfull3.txt`. I rerooted the tree at the _Sinorhizobium_ and _Bradyrhizobium_ clade since it is supposed to be an outgroup but seemed to nest with the _Mesorhizobium_ clade. 

A Mantel test was also performed to determine if rhizobia genetic distance was correlated with sharing the same host variety. To get the variety distance matrix (where samples of the same variety have a distance of 0 and samples of different varieties have a distance of 1), run the `makevarietymatrix.py` Python script on the provided file `varietysort.txt` (samples are in the order that matches how the alignment ordered them). 
The Mantel test was performed with the `mantel` function of the R package "Vegan", as well as a partial Mantel test controlling for geographic distance. 
There is also unused, commented code for the `mantel.rtest` function of the R package "ade4". See `makeMantel.r`.

### PCoA
Principal Coordinate Analysis was performed on the rhizobial phylogenetic distance using the R script `makepcoa.R`. To color it by species cluster, download the `clustorder.txt` file.

## Rhizobia genetic distance X geographic distance
(Note: since soils and seeds were taken from the same plants, the geographic distance is the same for both the rhizobia and their hosts.)

A Mantel test compares 2 distance matrices to test their correlation. To determine whether closely related bacteria are more likely to be found near each other, genetic distance was compared to geographic distance. (The same kind of test could be used to compare the genetic distance of the rhizobia to the genetic distance of their hosts for a more quantitative answer to the previous question.)

This was tested in R using the `mantel` function of "Vegan", as well as the `mantel.partial` function to control for variety.
There is also unused, commented code using 2 other packages: the `mantel.test` function of "ape" and the `mantel.rtest` function of "ade4". Note that the former takes the data as matrices while the latter takes dist objects. 

The geographic distance matrix was created using [Geographic Distance Matrix Generator](https://biodiversityinformatics.amnh.org/open_source/gdmg/). You can replicate this by running the program on the provided file `sitesFinal.txt` and naming the resulting matrix `GeoDistMatFinal.txt`. Select the `Full NxN Matrix` option.

See the file `makeMantel.R`.

Make sure that your input matrices are in the same order and have the same names for each entry. For some reason, the geographic distance matrix produced by GeographicDistanceMatrixGenerator listed 43U_bin.1 and 43U_bin.2 as having a distance of NaN instead of 0.00, so that had to be manually edited. 

To reorder your geographic sites (prior to putting them through GeographicDistanceMatrixGenerator!) to match the order of your genetic data, use the script found in `reorder.py`. For the input, read the genetic data into R from your alignment or tree using the appropriate lines in `makeMantel.R` but don't run the whole script. Then assign the row names (which are the order you want) to a variable, let's call it `o`, so `o <- row.names(as.matrix(phylodist))`. Write it to a file with `write.table(o, file="order.txt", row.names=FALSE)`. Then go into `order.txt` and remove the first line ("x"), and remove all the quotation marks with a simple search-and-replace. Finally, run `reorder.py`. This can also be used to resort `varietysort.txt`. Make sure your names match, you might have to do things like rename "77J_redo" to just "77J" or "1D_a" to "1D" if you are inconsistent with your naming, otherwise they will be missing.

## Permanova
A permanova was performed to further test the significance of geographic distance and variety using the `adonis2` function of "Vegan". These steps have also been added to `makeMantel.R`. 

Note that this step takes significantly longer than the Mantel test, so you may want to comment this section out if you don't need it. 

# Annotation:
Two alternate tools were used. The code is very similar for both. They start in the input folder and output into the parent folder containing that folder. Most of the code is just trimming the names of the files, such as "19_30C_S380_bin.1.fa". They all start with "19_" and most of the suffixes are just from assembly; the only meaningful part is the "30C" in this example, so we trim everything after that. 

This can be accomplished prior to annotation (such as for running Phylophlan with neater names) by running
```
for i in *.fa; do x=${i%_*}; y=${x%_*}.fa; mv $i $y; done
```

This iterates through every file with the ".fa" extension. `x=${i%_*}` trims the final underscore and everything after it (in this case "_bin.1.fa"). Then take that value and trim it the same way to remove the "_S380", then add the extension back in, leaving a neat "19_30C.fa" as the final file name. If you want to test this before actually changing the file names, replace `mv $i $y` with `echo $y` to simply print out a list of what the updated names would look like. If you are working with a format other than ".fa", either replace both instances of ".fa" with a different extension like ".fasta" or just omit the extension to iterate through all files regardless of extension. 
For example, replacing all ".fna" extensions with ".fa" can be accomplished with:
```
for i in *.fna; do x=${i%fna}fa; mv $i $x; done
```

To remove the "19_" from the beginning of the file names, the code is very similar. 
```
for i in *; do x=${i#*_}; mv $i $x; done
```

Running this on the original file would change "19_30C_S380_bin.1.fa" to "30C_S380_bin.1.fa"; running this on the shortened file "19_30C.fa" would result in "30C.fa", which PhyloPhlAn would read as just "30C" if ".fa" was specified as the extension.

## PGAP
To download PGAP, go to https://github.com/ncbi/pgap
```
for i in *; do x=${i%_*}; y=${x%_*}; sudo ~/pgap.py -r --taxcheck -o ../$y -g ./$i -s 'Mesorhizobium'; done
```
The code for the first batch of samples was originally run without the --taxcheck flag, so I reran the pipeline with --taxcheck-only and the output directory as taxcheck_$y so that it wouldn't have to go through the full annotation process. The taxonomy check gives the ANI compared to the most closely related species, so this flag is optional. 

## Prokka
To download Prokka, go to https://github.com/tseemann/prokka
```
for i in *; do x=${i%_*}; y=${x%_*}; prokka -outdir ../$y -prefix $y ./$i; done
```
I later ran an even shorter version that just removed the file extension since I had manually renamed most of the files at that point. I ran it from a more distant folder, which is why the outdir looks different.
```
for i in *; do x=${i%.*}; prokka -outdir ../../JoshuaProkka/finalrun/$x -prefix $x ./$i; done
```
# Symbiosis genes
Symbiosis genes are known to frequently undergo horizontal gene transfer, and are often transmitted together. We can make tanglegrams to visualize how the phylogeny of the symbiosis genes may differ from the overall phylogeny. 
## Extraction

Symbiosis genes were occasionaly missing from annotations, so they were extracted directly from the metagenomes by annotating them with KofamScan. The code for that can be found at https://github.com/jpod1010/nodule_metagenomics. 

Genes were located in KofamScan and matched to proteins using the code in the `getGene.py` file on this repository. Nucleotide data was later obtained with Prodigal to be more precise than amino acids, but the script still runs the same by accessing the KofamScan locations, you just have to change the input file of the proteins to be your nucleotides.

I excluded 19-73C due to it containing a mix of _Rhizobium_ and _Mesorhizobium_, 19-9A because it was _Sinorhizobium_, 19-39C, 19-70G, and 19-81J due to being low quality, the old runs of 19-77J, and 19-41A due to it not detecting _nifH_ even though it detected _nodA_ and _nodB_. I also later removed the "19" from all names.

I also excluded 19-1F bin 1 and 2, 19-9F bin 1 and 2, and 19-43U bin 1 and 2 and reran the phylogeny so that the samples used in the symbiosis gene trees (which don't take bins into account) would match the phylogeny. 

Core genes were present in the regular annotations, so a simpler script to get those from Prokka can be found in the `getNucGenesFromProkka.py` file.

## Alignment

Alignments were produced with MAFFT using the following code (swapping "NifH" for "nodA" or "nodB" as appropriate):
```
"/usr/bin/mafft"  --auto --reorder "JoshuaMelnickData/metagenome_NifH.fasta" > "nifHalign.aln"
```

## Phylogenies

RAxML was called for each symbiosis gene using the same settings as we used for bootstrapping the whole phylogeny above. `-w`, `-s`, and `-n` were changed to match the gene names. For example: 
```
/home/grillo/miniconda3/envs/phylophlan/bin/raxmlHPC-PTHREADS-SSE3 -f a -x 12345 -p 1989 -# 100 -m GTRCAT -T 2 -w /home/grillo/nifHphylo -s /home/grillo/nifHalign.aln -n nifHphylogeny.tre
```
`-m` has also been changed to fit an amino acid substitution model; I selected the one that Phylophlan would use by default for an amino acid supermatrix. If you use amino acids, replace `-m GTRCAT` with `-m PROTCATLG`. If you use `getNucGenesFromProkka.py` or the Prodigal method, you will have nucleotides, so in that case stick with `-m GTRCAT`.

Make sure there aren't any duplicate names in the alignment or else the program won't run.

## Concatenate alignments
Put the 3 gene alignments in a shared folder, in this case called `genealignments`.

### IQTree
_This method is unused; it outputs a useful tree, but it doesn't provide the actual concatenated alignment._

Call [IQTree](http://www.iqtree.org/), but instead of using one alignment with the `-s` flag, just call their shared folder. We will do regular bootstrapping.

```
~/Downloads/iqtree-3.0.0-Linux-intel/bin/iqtree3 -s ~/genealignments -b 100
```
### MEGA
Convert the .aln files to .fasta files by renaming them. Make sure they are all in one folder that contains no other files. [Concatenate the alignments](https://www.megasoftware.net/web_help_10/Concatenation_Utility.htm) with [MEGA](https://www.megasoftware.net/).

## Construct a tanglegram
The R package "ape" was used to read the trees and to create the figure. See the file `makeTanglegram.R`.

## Robinson-Foulds distance
### ete3 (currently unused)
The similarity of two phylogenetic trees can be calculated by finding their Robinson-Foulds distance. This was done using [ete3](https://etetoolkit.org/documentation/ete-compare/).

```
ete3 compare -t genealignments/iqtestfinal/genealignments.treefile -r JoshuaPhylophlan/genomesnobins_phylophlan/boot/RAxML_bipartitions.genomesnobins_boot.tre --unrooted
```
`-t` is the tree to compare, in this case the concatenated symbiosis gene tree.
`-r` is the whole genome phylogeny, which is used as the reference.

### TreeDistance
The normalized Robinson-Foulds distance was also calculated with the R package "TreeDist" using the `RobinsonFoulds` function. Because nRF values were so high, I also used this package's unique metric, generalized Robinson-Foulds, found in the `TreeDistance` (or `ClusteringInfoDistance`) function, which provides a value more in line with my expectations.

See the R script `getTreeDistances.R`.

# Map figures
Maps were made using code modified from [Jeremy Davis](https://doi.org/10.1007/s10886-024-01529-3). It was originally meant to use scatterpies but I changed it to just use points. The metadata is in the file `mapmetadata.txt`. The script to generate the maps is `makemap.R`. 

The first few maps try to use every sample, but that's too much data. The third-to-last map is the best variety map, which just does them by sites. The second-to-last map is by ANI species cluster, and the last map is by rhizobial genus. The datapoints are nudged to reduce overlap.
