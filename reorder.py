#reorder sites based on order of alignment/tree so that matrices match

#read genetic order
with open("order.txt", "r") as f:
    names = f.readlines()
#strip newlines
for n in range(len(names)):
    names[n] = names[n].strip()

#get list of sites in the old order with their coordinates
with open("sitesFinal.txt", "r") as s:
    old = s.readlines()
#or for reordering the variety file, do this instead
#with open("varietysort.txt", "r") as s:
    #old = s.readlines()

#create new file with the sites reordered to match the genetic order
with open("newOrder.txt", "a") as x:
    #iterate through genetic order
    for name in names:
        #iterate through old site order until you find the one you are looking for
        for site in old:
            if site.split('\t')[0] == name:
                x.write(site)
