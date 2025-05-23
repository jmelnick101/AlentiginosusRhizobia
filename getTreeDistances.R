library(ape)
library(TreeDist)

#gene trees
nifH <- read.tree("nifHphylo/RAxML_bestTree.nifHphylogeny.tre")
nodA <- read.tree("nodAphylo/RAxML_bestTree.nodAphylogeny.tre")
nodB <- read.tree("nodBphylo/RAxML_bestTree.nodBphylogeny.tre")

#concatenated nifH, nodA, and nodB trees
#con <- read.tree("genealignments/iqtestfinal/genealignments.treefile")
con <- read.tree("concatPhylo/RAxML_bipartitions.concatPhylogeny.tre")
#housekeeping gene
#recA <- read.tree("recAphylo/RAxML_bestTree.RecAphylogeny.tre")

#wgs phylogeny
#wgs <- read.tree("JoshuaPhylophlan/allmesogenomes_phylophlan/RAxML_bestTree.allmesogenomes_refined.tre")
wgs <- read.tree("JoshuaPhylophlan/genomesnobins_phylophlan/boot/RAxML_bipartitions.genomesnobins_boot.tre")

#just mesorhizobium
#mesowgs <- read.tree("JoshuaPhylophlan/justmeso_phylophlan/boot/RAxML_bipartitions.justmeso_boot.tre")
#mesosym <- read.tree("justmesosymphylo/RAxML_bipartitions.justmesosym_boot.tre")
#just allomesorhizobium
#allowgs <- read.tree("JoshuaPhylophlan/justallo_phylophlan/boot/RAxML_bipartitions.justallo_boot.tre")
#allosym <- read.tree("justallosymphylo/RAxML_bipartitions.justallosym_boot.tre")

#just mesorhizobium
#RobinsonFoulds(mesosym,mesowgs,normalize=TRUE)
#TreeDistance(mesosym,mesowgs)
#ClusteringInfoDistance(mesosym,mesowgs)
#ExpectedVariation(mesosym,mesowgs)
#just allomesorhizobium
#RobinsonFoulds(allosym,allowgs,normalize=TRUE)
#TreeDistance(allosym,allowgs)
#ClusteringInfoDistance(allosym,allowgs)
#ExpectedVariation(allosym,allowgs)

#normalized Robinson-Foulds distance
RobinsonFoulds(con,wgs,normalize=TRUE)

RobinsonFoulds(nodA,con,normalize=TRUE)
RobinsonFoulds(nodB,con,normalize=TRUE)
RobinsonFoulds(nifH,con,normalize=TRUE)

RobinsonFoulds(nodA,nodB,normalize=TRUE)
RobinsonFoulds(nodA,nifH,normalize=TRUE)
RobinsonFoulds(nodB,nifH,normalize=TRUE)

RobinsonFoulds(nodA,wgs,normalize=TRUE)
RobinsonFoulds(nodB,wgs,normalize=TRUE)
RobinsonFoulds(nifH,wgs,normalize=TRUE)

#tree distance
TreeDistance(con,wgs) #normalized
ClusteringInfoDistance(con,wgs) #unnormalized
ExpectedVariation(con,wgs) #compare unnormalized to bottom one

TreeDistance(nodA,con)
TreeDistance(nodB,con)
TreeDistance(nifH,con)

TreeDistance(nodA,nodB)
TreeDistance(nodA,nifH)
TreeDistance(nodB,nifH)

TreeDistance(nodA,wgs)
TreeDistance(nodB,wgs)
TreeDistance(nifH,wgs)
