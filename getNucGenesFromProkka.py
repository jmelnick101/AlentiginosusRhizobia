from Bio import SeqIO
import os

#replace with any gene you need
gene = "recA"

#iterate through every folder produced by Prokka (one per genome) in a directory I called finalrun
for annotation in os.listdir("finalrun"):
    #search through each folder's ffn file - this is a list of gene names with their nucleotides; for amino acids, replace ffn with faa
    recs = SeqIO.parse("{0}/{0}.ffn".format(annotation), "fasta")
    #loop through every gene
    for record in recs:
        #genes have unnecessary identifiers between the > and the actual gene name, so just check if it's in the line rather than the full name
        if gene in record.id:
            with open("metagenome_{}.fasta".format(gene), "a") as g:
                #write to a fasta file
                g.write(">"+annotation+"\n"+str(record.seq)+"\n")

