# code adapted from https://doi.org/10.1007/s10886-024-01529-3 by Jeremy S Davis
# He wrote most of it, I altered it to add points instead of pie charts and to fit my data

#here is the general examples and documentation for scatterpie. 
#https://cran.r-project.org/web/packages/scatterpie/vignettes/scatterpie.html
#run this below to install
#install.packages('scatterpie')

library(ggplot2)
library(scatterpie)
library(RColorBrewer)
library(mapdata)
library(scales)
library(dplyr)

#reminder to set your working directory
setwd("C:/Users/jmeln/Downloads")

#you will also need a map. There are many ways to do maps in R, but the simplest is to use mapdata
#the way this works best is for each country you should make sure you call them individually in ggplot. pretty easy. 
#you could use "world" but it excludes stuff like lakes...important for my midwest samples. 
usa <- map_data("state")
canada <- map_data('worldHires','Canada')
Mexico <- map_data("worldHires","Mexico")
world <- map_data("world")

#here are the data files
lent_data <- read.table(file="mapmetadata.txt",header=TRUE)
#need to omit points with missing data
lent_data <- na.omit(lent_data)

#This is a color palette that Jeremy made with custom colors. The position in the 
#vector is important for the color that ends up on the figure. 
#this is a vector of pretty colorblined friendly colors
palette1 <- c("#66C2A5","#FC8D62","#8DA0CB","#E78AC3","#A6D854")
show_col(palette1)

#ok, here is the gory ggplot. Jeremy documented most of the parts. 
lent_map <- ggplot() + #give the plot a name, append ggplot with nothing in it and + for next line
  geom_polygon(data = usa, aes(x=long, y = lat, group = group), 
               fill = "Grey95", color="black") + #The first polygon here is the US. input exactly as I have here. You can alter the shade of the fill or lines if you want.
  geom_polygon(data = Mexico, aes(x=long, y = lat, group = group), 
               fill = "Grey95", color="black") + #Mexico, same deal.
  geom_point(data = lent_data, aes(x=Longitude, y=Latitude,col=Variety)) + #x/y should always be long/lat. r is radius and i set it to the "het" variable here. #this is where you actually put the columns of data you are intending to use. it wants the NAMES so usually I call them like this with colnames() and the relevant columns inside.
  scale_fill_manual(values = palette1) + #this is to manually choose the fill colors.
  coord_fixed(xlim = c(-120, -111),  ylim = c(30, 41.2), ratio = 1)+ #this is important. It determines the window of map space you are plotting. I have set these limits to contain the area of North America I want to display.
  theme(text = element_blank(), legend.text = element_text(size = 10), #all of this theme stuff below is personal preference settings I use to remove background color, lines, axes, (not needed here)
        #legend.position = "none", #if you want the legend gone, unhash this line. 
        axis.ticks = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
lent_map

#there are obvious issues here. For one, sites overlap. But the bigger one is at each site there are many/multiple points
#we have WAY too many points. Its not reasonable to plot 104 individuals on a map. 
#So lets try an aggregate approach.
lent.site <- lent_data %>% group_by(Site) %>% summarise(
  count = n(),
  Variety = c(unique(Variety)),
  Lat = mean(Latitude),
  Long = mean(Longitude)
)

mean_map <- ggplot() + #give the plot a name, append ggplot with nothing in it and + for next line
  geom_polygon(data = usa, aes(x=long, y = lat, group = group), 
               fill = "Grey95", color="black") + #The first polygon here is the US. input exactly as I have here. You can alter the shade of the fill or lines if you want.
  geom_polygon(data = Mexico, aes(x=long, y = lat, group = group), 
               fill = "Grey95", color="black") + #Mexico, same deal.
  geom_point(data = lent.site, aes(x=Long,y=Lat,col=Variety,size=count)) + #x/y should always be long/lat. r is radius and i set it to the "het" variable here. #this is where you actually put the columns of data you are intending to use. it wants the NAMES so usually I call them like this with colnames() and the relevant columns inside.
  scale_size_continuous(range=c(1.5,3)) + 
  scale_fill_manual(values = palette1) + #this is to manually choose the fill colors.
  coord_fixed(xlim = c(-120, -111),  ylim = c(30, 41.2), ratio = 1)+ #this is important. It determines the window of map space you are plotting. I have set these limits to contain the area of North America I want to display.
  theme(text = element_blank(), legend.text = element_text(size = 10), #all of this theme stuff below is personal preference settings I use to remove background color, lines, axes, (not needed here)
        #legend.position = "none", #if you want the legend gone, unhash this line. 
        axis.ticks = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
mean_map

#This is pretty good, but you still have overlapping points. The best fix for this Jeremy knows of is to manually bump the points.
#Below is how we did this. We make alt.Long and alt.Lat with manual "nudging" of the coordinates
#first, sort by site to make referencing easier
lent.site <- lent.site[order(lent.site$Site),]

#now we are adding "nudges" on lat/long to move things. Doing it this way lets me play with it easier.
lent.site$alt.lat <- lent.site$Lat + c(0,0,0.25,0,0.25,0,0, #this is any site starting with a 1
                                       0,-0.2,0,0,0, #every site with a 2, etc.
                                       0.2,0,0,0,0,0,
                                       0,0,0,0,0,0,0,0.2,-0.2,0.15,
                                       0,0,0,
                                       0.3,0,0,
                                       0,0,0,0,0,0,0,0,0,
                                       0,-0.3,0.15,0.24,-0.15,-0.2,0,0,
                                       0,0,0)
lent.site$alt.long <- lent.site$Long + c(0,0,-0.25,0,0.15,0,0, #this is any site starting with a 1
                                         0,0,0,0,0, #every site with a 2, etc.
                                         0.3,0,0,0,0,0,
                                         0,0,0,0,0,0,0,-0.3,0.2,0.15,
                                         0,0,0,
                                         0,0,0,
                                         0,0,0,0,0,0,0,0,0,
                                         0,-0.2,-0.15,0.25,-0.3,0.15,0,0.3,
                                         0,0,0)

mean_map2 <- ggplot() + #give the plot a name, append ggplot with nothing in it and + for next line
  geom_polygon(data = usa, aes(x=long, y = lat, group = group), 
               fill = "Grey95", color="black") + #The first polygon here is the US. input exactly as I have here. You can alter the shade of the fill or lines if you want.
  geom_polygon(data = Mexico, aes(x=long, y = lat, group = group), 
               fill = "Grey95", color="black") + #Mexico, same deal.
  geom_point(data = lent.site,aes(x=Long,y=Lat), color = "black",size=1)+
  geom_segment(data=lent.site,aes(x=Long, y=Lat, xend=alt.long,yend=alt.lat))+
  geom_point(data = lent.site, aes(x=alt.long, y=alt.lat,col=Variety,size=count)) + #x/y should always be long/lat. r is radius and i set it to the "het" variable here. 
  scale_size_continuous(range=c(2,4)) + #minimum and maximum size of points
  scale_fill_manual(values = palette1) + #this is to manually choose the fill colors.
  coord_fixed(xlim = c(-120, -111),  ylim = c(30, 41.2), ratio = 1)+ #this is important. It determines the window of map space you are plotting. I have set these limits to contain the area of North America I want to display.
  theme(text = element_blank(), legend.text = element_text(size = 10), #all of this theme stuff below is personal preference settings I use to remove background color, lines, axes, (not needed here)
        #legend.position = "none", #if you want the legend gone, unhash this line. 
        axis.ticks = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
mean_map2

###########################################################################
#Now we'll make a map based on the ANI clusters. 
#We'll still sort by site to reduce the number of points, but there will be multiple per site, sometimes even per soil

lent.clust <- lent_data %>% group_by(Site) %>% summarise(
  count = n(),
  Variety = c(unique(Variety)),
  cluster = as.character(c(unique(ANI_cluster))), #as.character is necessary because it treats them as numbers and colors with a gradient otherwise
  Lat = mean(Latitude),
  Long = mean(Longitude)
)

#This is pretty good, but you still have overlapping points. The best fix for this Jeremy knows of is to manually bump the points.
#Below is how we did this. We make alt.Long and alt.Lat with manual "nudging" of the coordinates
#first, sort by site to make referencing easier
lent.clust <- lent.clust[order(lent.clust$Site),]

#now we are adding "nudges" on lat/long to move things. Doing it this way lets me play with it easier.
lent.clust$alt.lat <- lent.clust$Lat + c(0.15,-0.15,-0.3,0,0.25,0,0.25,0.3,0,0, #this is any site starting with a 1
                                       0,-0.2,0,0,0, #every site with a 2, etc.
                                       0.2,0,0,0,0,0,
                                       0,0.2,-0.15,0,0.1,0,0.3,0,0,0,0.2,-0.2,0.15,
                                       0,0.15,0,0,
                                       0.3,0,0.15,0,-0.15,
                                       0,0.25,0,0.2,0,0,0,-0.25,-0.2,0,-0.3,0,0.3,0.28,-0.1,0,0.2,
                                       0,0.19,-0.3,0.15,0.24,-0.15,-0.2,0,0,
                                       0,0.15,0.25,0,0)
lent.clust$alt.long <- lent.clust$Long + c(0,-0.25,0.15,0,-0.25,0,0.15,-0.3,0,0, #this is any site starting with a 1
                                         0,0,0,0,0, #every site with a 2, etc.
                                         0.3,0,0,0,0,0,
                                         0,0,0.3,0,0.25,0,0.3,0,0,0,-0.3,0.2,0.15,
                                         0,0.15,0,0,
                                         0,0,0.15,0,-0.15,
                                         0,0.25,0,0.2,0,0,0,0.15,-0.2,0,-0.3,0,0.3,0,-0.1,0,0.2,
                                         0,-0.2,-0.2,-0.15,0.25,-0.3,0.15,0,0.3,
                                         0,0.25,-0.25,0,0)

cluster_map <- ggplot() + #give the plot a name, append ggplot with nothing in it and + for next line
  geom_polygon(data = usa, aes(x=long, y = lat, group = group), 
               fill = "Grey95", color="black") + #The first polygon here is the US. input exactly as I have here. You can alter the shade of the fill or lines if you want.
  geom_polygon(data = Mexico, aes(x=long, y = lat, group = group), 
               fill = "Grey95", color="black") + #Mexico, same deal.
  geom_point(data = lent.clust,aes(x=Long,y=Lat), color = "black",size=1)+
  geom_segment(data=lent.clust,aes(x=Long, y=Lat, xend=alt.long,yend=alt.lat))+
  geom_point(data = lent.clust, aes(x=alt.long, y=alt.lat,col=cluster,size=count)) + #x/y should always be long/lat. r is radius and i set it to the "het" variable here. 
  scale_size_continuous(range=c(2,4)) + #minimum and maximum size of points
  scale_fill_manual(values = palette1) + #this is to manually choose the fill colors.
  coord_fixed(xlim = c(-120, -111),  ylim = c(30, 41.2), ratio = 1)+ #this is important. It determines the window of map space you are plotting. I have set these limits to contain the area of North America I want to display.
  theme(text = element_blank(), legend.text = element_text(size = 10), #all of this theme stuff below is personal preference settings I use to remove background color, lines, axes, (not needed here)
        #legend.position = "none", #if you want the legend gone, unhash this line. 
        axis.ticks = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
cluster_map

###########################################################################
#Now we'll make a map based on the genus. 
#We'll still sort by site to reduce the number of points, but there will be multiple per site, sometimes even per soil


lent.gen <- lent_data %>% group_by(Site) %>% summarise(
  count = n(),
  Variety = c(unique(Variety)),
  Genus = c(unique(Genus)),
  Lat = mean(Latitude),
  Long = mean(Longitude)
)

#This is pretty good, but you still have overlapping points. The best fix for this Jeremy knows of is to manually bump the points.
#Below is how we did this. We make alt.Long and alt.Lat with manual "nudging" of the coordinates
#first, sort by site to make referencing easier
lent.gen <- lent.gen[order(lent.gen$Site),]

#now we are adding "nudges" on lat/long to move things. Doing it this way lets me play with it easier.
lent.gen$alt.lat <- lent.gen$Lat + c(0,0,0.25,0,0.25,0,-0.25,0, #this is any site starting with a 1
                                       0,0.15,0,0,0, #every site with a 2, etc.
                                       0.2,0,0,0,0,0,
                                       0,0,0,0,0,0,0,0.2,-0.2,0.15,
                                       0,0,0,
                                       0.3,0,0.2,0,
                                       0,0.2,0,0,0,0,-0.2,0,0,0,0,
                                       0,-0.3,0.15,0.24,-0.15,-0.2,0,0,
                                       0,0,0)
lent.gen$alt.long <- lent.gen$Long + c(0,0,-0.25,0,0.15,-0.3,0,0, #this is any site starting with a 1
                                         0,0.2,0,0,0, #every site with a 2, etc.
                                         0.3,0,0,0,0,0,
                                         0,0,0,0,0,0,0,-0.3,0.2,0.15,
                                         0,0,0,
                                         0,0,0.2,0,
                                         0,0.2,0,0,0,0,-0.2,0,0,0,0,
                                         0,-0.2,-0.15,0.25,-0.3,0.15,0,0.3,
                                         0,0,0)

genus_map <- ggplot() + #give the plot a name, append ggplot with nothing in it and + for next line
  geom_polygon(data = usa, aes(x=long, y = lat, group = group), 
               fill = "Grey95", color="black") + #The first polygon here is the US. input exactly as I have here. You can alter the shade of the fill or lines if you want.
  geom_polygon(data = Mexico, aes(x=long, y = lat, group = group), 
               fill = "Grey95", color="black") + #Mexico, same deal.
  geom_point(data = lent.gen,aes(x=Long,y=Lat), color = "black",size=1)+
  geom_segment(data=lent.gen,aes(x=Long, y=Lat, xend=alt.long,yend=alt.lat))+
  geom_point(data = lent.gen, aes(x=alt.long, y=alt.lat,col=Genus,size=count)) + #x/y should always be long/lat. r is radius and i set it to the "het" variable here. 
  scale_size_continuous(range=c(2,4)) + #minimum and maximum size of points
  scale_fill_manual(values = palette1) + #this is to manually choose the fill colors.
  coord_fixed(xlim = c(-120, -111),  ylim = c(30, 41.2), ratio = 1)+ #this is important. It determines the window of map space you are plotting. I have set these limits to contain the area of North America I want to display.
  theme(text = element_blank(), legend.text = element_text(size = 10), #all of this theme stuff below is personal preference settings I use to remove background color, lines, axes, (not needed here)
        #legend.position = "none", #if you want the legend gone, unhash this line. 
        axis.ticks = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
genus_map


