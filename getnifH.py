import os
from Bio import SeqIO

for file in os.listdir('Downloads/metagenome_assemblies-selected'):
    #this section looks for the NifH gene with the top score in the Kofamscan file, located in the "metagenome_assemblies-selected" folder of my Downloads. 
    #in Kofamscan, genes with a score higher than the threshold will start with an asterisk, so we'll just take the first NifH sequence with an asterisk in each file
    #then we take the second column of that with the cut command to obtain the location
    #we pipe that location to a file called "genelocations.txt", overwriting whatever is there
    os.system('grep NifH {} | grep "*" | cut -f 2 | head -n 1 > genelocations.txt'.format("~/Downloads/metagenome_assemblies-selected/"+file))
    with open("genelocations.txt", "r") as loc:
        x = loc.read()
        x = x.strip()
    #do the biopython parser
    for p in os.listdir('Downloads/metagenome_assemblies-selected_proteins'):
        #iterate through protein list
        site = p.split("_")
        name = site[0]+"_"+site[1]
        #prefix name
        if file[0:6] == p[0:6]:
            #read the fasta containing all the proteins with Biopython
            recs = SeqIO.parse("Downloads/metagenome_assemblies-selected_proteins/{}".format(p), "fasta")
            for record in recs:
                #find the location that matches the location of NifH from the Kofamscan
                if record.id == x:
                    with open("metagenome_nifH.fasta","a") as m:
                        #append it to a file called metagenome_nifH.fasta
                        m.write(">"+name+"\n"+str(record.seq)+"\n")
