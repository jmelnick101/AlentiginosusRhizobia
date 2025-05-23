library(ape)
library(seqinr)
library(ggplot2)

#read alignment
phylodist <- as.dist(dist.alignment(read.alignment("JoshuaPhylophlan/allmesogenomes_phylophlan/allmesogenomes_concatenated.aln",format="fasta")),diag=TRUE) #full 104 genomes
#read variety
v <- read.table("varietysort.txt",col.names = c("sample","varietyname"))
#read clusters
clust <- read.table("clustorder.txt",col.names = c("sample","cluster"))

#black and white version
biplot.pcoa(pcoa(phylodist))

p <- pcoa(phylodist)
#pcoa_df <- data.frame(PC1=p$vectors[,1],PC2=p$vectors[,2],var=v$varietyname)
#ggplot(pcoa_df, aes(x=PC1,y=PC2,color=var)) + geom_point(size=3) + geom_text(label=v$sample,hjust=0,vjust=0)
pcoa_df <- data.frame(PC1=p$vectors[,1],PC2=p$vectors[,2],cluster=as.character(clust$cluster))
ggplot(pcoa_df, aes(x=PC1,y=PC2,color=cluster)) + geom_point(size=3) + geom_text(label=v$sample,hjust=0,vjust=0)
