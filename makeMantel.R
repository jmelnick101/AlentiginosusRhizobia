library(seqinr)
library(ape)
library(ade4)

#import geographic distance matrix
geodist <- as.dist(read.table("GeoDistMatFinal.txt"),diag=TRUE)

#import genetic distance matrix from alignment
phylodist <- as.dist(dist.alignment(read.alignment("JoshuaPhylophlan/allmesogenomes_phylophlan/allmesogenomes_concatenated.aln",format="fasta")),diag=TRUE)

variety <- as.dist(read.table("varietymatrix",check.names=FALSE),diag=TRUE)

#ade4
mantel.rtest(phylodist,geodist) #genetic distance by geographic distance

mantel.rtest(phylodist,variety) #genetic distance by variety

#ape
#mantel.test(as.matrix(geodist),as.matrix(phylodist))
