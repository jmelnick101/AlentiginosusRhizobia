# AlentiginosusRhizobia
Code to work with genomes for the rhizobia associated with Astragalus lentiginosus.

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

# Annotation:
Two alternate tools were used. The code is very similar for both. They start in the input folder and output into the parent folder containing that folder. Most of the code is just trimming the names of the files, such as "19_30C_S380_bin.1.fa". They all start with "19_" and most of the suffixes are just from assembly; the only meaningful part is the "30C" in this example, so we trim everything after that. 
## PGAP
```
for i in *; do x=${i%_*}; y=${x%_*}; sudo ~/pgap.py -r --taxcheck -o ../$y -g ./$i -s 'Mesorhizobium'; done
```
The code for the first batch of samples was originally run without the --taxcheck flag, so I reran the pipeline with --taxcheck-only and the output directory as taxcheck_$y so that it wouldn't have to go through the full annotation process. The taxonomy check gives the ANI compared to the most closely related species, so this flag is optional. 

## Prokka
```
for i in *; do x=${i%_*}; y=${x%_*}; prokka -outdir ../$y -prefix $y ./$i; done
```
