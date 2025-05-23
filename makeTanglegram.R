library(ape)

#gene trees
#nifH <- read.tree("nifHphylo/RAxML_bestTree.nifHphylogeny.tre")
#nodA <- read.tree("nodAphylo/RAxML_bestTree.nodAphylogeny.tre")
#nodB <- read.tree("nodBphylo/RAxML_bestTree.nodBphylogeny.tre")

#concatenated nifH, nodA, and nodB trees
#con <- read.tree("genealignments/iqtestfinal/genealignments.treefile")
con <- read.tree("concatPhylo/RAxML_bipartitions.concatPhylogeny.tre")
#housekeeping gene
#recA <- read.tree("recAphylo/RAxML_bestTree.RecAphylogeny.tre")

#wgs phylogeny
#wgs <- read.tree("JoshuaPhylophlan/allmesogenomes_phylophlan/RAxML_bestTree.allmesogenomes_refined.tre")
wgs <- read.tree("JoshuaPhylophlan/genomesnobins_phylophlan/boot/RAxML_bipartitions.genomesnobins_boot.tre")

#just mesorhizobium trees
#mesowgs <- read.tree("JoshuaPhylophlan/justmeso_phylophlan/boot/RAxML_bipartitions.justmeso_boot.tre")
#mesosym <- read.tree("justmesosymphylo/RAxML_bipartitions.justmesosym_boot.tre")
#just allomesorhizobium trees
#allowgs <- read.tree("JoshuaPhylophlan/justallo_phylophlan/boot/RAxML_bipartitions.justallo_boot.tre")
#allosym <- read.tree("justallosymphylo/RAxML_bipartitions.justallosym_boot.tre")

#link the matching labels with a line; both trees should have the same labels
association <- cbind(con$tip.label, con$tip.label)
#association <- cbind(mesowgs$tip.label, mesowgs$tip.label)
#association <- cbind(allowgs$tip.label, allowgs$tip.label)

#make tanglegram
cophyloplot(con,wgs,association, gap=10,length.line=0,space=100,rotate=TRUE)
#cophyloplot(mesosym,mesowgs,association, gap=10,length.line=0,space=100,rotate=TRUE)
#cophyloplot(allosym,allowgs,association, gap=10,length.line=0,space=100,rotate=TRUE)
