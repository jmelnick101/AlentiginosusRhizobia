library(seqinr)
library(ape)
library(ade4)

#import geographic distance matrix
geodist <- as.dist(read.table("GeoDistMatFinal.txt"),diag=TRUE)

#import genetic distance matrix from alignment
phylodist <- as.dist(dist.alignment(read.alignment("JoshuaPhylophlan/allmesogenomes_phylophlan/allmesogenomes_concatenated.aln",format="fasta")),diag=TRUE)

#ade4
mantel.rtest(geodist,phylodist)

#ape
mantel.test(as.matrix(geodist),as.matrix(phylodist))
