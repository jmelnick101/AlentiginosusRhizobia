library(seqinr)
library(vegan)
#library(ade4)
#library(ape)

#import geographic distance matrix
geodist <- as.dist(read.table("GeoDistMatFinal.txt"),diag=TRUE)

#import genetic distance matrix from alignment
phylodist <- as.dist(dist.alignment(read.alignment("JoshuaPhylophlan/allmesogenomes_phylophlan/allmesogenomes_concatenated.aln",format="fasta")),diag=TRUE)

#if samples are the same variety, they have distance of 0; if they are different varieties, they have distance of 1
variety <- as.dist(read.table("varietymatrix",check.names=FALSE),diag=TRUE)

#vegan
mantel(phylodist,geodist) #genetic distance by geographic distance
mantel.partial(phylodist,geodist,variety) #genetic distance by geographic distance, controlling for variety

mantel(phylodist,variety) #genetic distance by variety
mantel.partial(phylodist,variety,geodist) #genetic distance by variety, controlling for geographic distance

#mantel(geodist,variety) #geographic distance by variety (not the focus of this study)
#mantel.partial(geodist,variety,phylodist) #geographic distance by variety, controlling for genetic distance

#permanovas
#v <- read.table("varietysort.txt",col.names = c("sample","varietyname"))
vxg <- adonis2(as.vector(phylodist) ~ as.vector(variety) * as.vector(geodist), by="terms")
vxg #variety first, geography second
gxv <- adonis2(as.vector(phylodist) ~ as.vector(geodist) * as.vector(variety), by="terms")
gxv #geography first, variety second

#ade4
#mantel.rtest(phylodist,geodist) #genetic distance by geographic distance
#mantel.rtest(phylodist,variety) #genetic distance by variety

#ape
#mantel.test(as.matrix(geodist),as.matrix(phylodist))
