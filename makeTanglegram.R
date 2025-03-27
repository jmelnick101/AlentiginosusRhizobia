library(ape)

#gene tree
nifh <- read.tree("nifHphylo/RAxML_bestTree.nifHphylogeny.tre")

#wgs phylogeny
wgs <- read.tree("JoshuaPhylophlan/allmesogenomes_phylophlan/RAxML_bestTree.allmesogenomes_refined_short.tre")

#link the matching labels with a line; both trees should have the same labels
association <- cbind(wgs$tip.label, wgs$tip.label)

#make tanglegram
cophyloplot(wgs,nifh,association, gap=5,length.line=0,space=100)