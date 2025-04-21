#read data, each line being the sample and the variety separated by a tab
with open("varietysort.txt", "r") as v:
    s = v.readlines()
#remove the newline character and split by tab
for x in range(len(s)):
    s[x] = s[x].strip().split('\t')
#make dictionary
d = {}
#make list of just samples
samplist = []
#iterate through list of samples and varieties
for i in s:
    #add sample to samplist
    samplist.append(i[0])
    #for each datapoint, add to the dictionary with the sample as the key and the variety as the value
    d[i[0]] = i[1]
#create output file by initializing header row
with open("varietymatrix", "w") as f:
    f.write('\t'.join(samplist))
#iterate through each sample as the rows of the matrix
for r in samplist:
    #add the sample name as the row header
    with open("varietymatrix", "a") as n:
        n.write('\n' + r + '\t')
    #make list of matches
    matchlist = []
    #iterate through each sample as the columns of the matrix
    for c in samplist:
        #if they are the same variety, they have a distance of 0
        if d[c] == d[r]:
            matchlist.append('0')
        #if they are a different variety, they have a distance of 1
        else:
            matchlist.append('1')
    #add the match data for the row to the matrix
    with open("varietymatrix", "a") as m:
        m.write('\t'.join(matchlist))

