library(ape)

#gene trees
nifH <- read.tree("nifHphylo/RAxML_bestTree.nifHphylogeny.tre")
nodA <- read.tree("nodAphylo/RAxML_bestTree.nodAphylogeny.tre")
nodB <- read.tree("nodBphylo/RAxML_bestTree.nodBphylogeny.tre")

#wgs phylogeny
wgs <- read.tree("JoshuaPhylophlan/allmesogenomes_phylophlan/RAxML_bestTree.allmesogenomes_refined.tre")

#link the matching labels with a line; both trees should have the same labels
association <- cbind(nodA$tip.label, nodA$tip.label)

#make tanglegram
cophyloplot(nodA,nodB,association, gap=10,length.line=0,space=100,rotate=TRUE)
