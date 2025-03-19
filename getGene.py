import os
from Bio import SeqIO

#modify the gene to be whatever you are looking for, it doesn't have to be NifH
gene = "NifH"

for file in os.listdir('meta_kofamscan'):
    #this section looks for the desired gene with the top score in the Kofamscan file, located in the "meta_kofamscan" folder of my Downloads. 
    #in Kofamscan, genes with a score higher than the threshold will start with an asterisk, so we'll just take the first matching sequence with an asterisk in each file
    #then we take the second column of that with the cut command to obtain the location
    #we pipe that location to a file called "genelocations.txt", overwriting whatever is there
    os.system('grep {0} {1} | grep "*" | cut -f 2 | head -n 1 > genelocations.txt'.format(gene,"meta_kofamscan/"+file))
    with open("genelocations.txt", "r") as loc:
        x = loc.read()
        x = x.strip()
    #do the biopython parser
    for p in os.listdir('meta_prot'):
        #iterate through protein list
        site = p.split("_")
        #prefix name
        if site[0] == "19":
            name = site[0]+"_"+site[1]
        #some of the genomes weren't give the 19 prefix, but this was inconsistent, so I'll give it to all of them
        else:
            name = "19_" + site[0]
        #prefix name
        if file[0:6] == p[0:6]:
            #read the fasta containing all the proteins with Biopython
            recs = SeqIO.parse("meta_prot/{}".format(p), "fasta")
            for record in recs:
                #find the location that matches the location of the gene from the Kofamscan
                if record.id == x:
                    with open("metagenome_{}.fasta".format(gene),"a") as m:
                        #append it to a file called metagenome_{gene}.fasta
                        m.write(">"+name+"\n"+str(record.seq)+"\n")
