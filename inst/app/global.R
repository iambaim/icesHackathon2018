# Get Data
#dataInputFile <- "/home/user/Documents/IE_IGFS_LFs.csv"
dataInputFile <- system.file("extdata", "IE_IGFS_LFs.csv", package = "icesHackathon2018G3")
print(dataInputFile)
parsedData <- read_csv(dataInputFile)

# Assuming we operate on one haulSubsetType of quarters, cruise, ship, and countries
maxYear <- max(unique(parsedData$Year))

# Color
Current_color <- "#e69500"
Hist_color <- "#00c4e6"

# Get the last haul of the selected year
getLastHaul <- function(year) {
  max(getHauls(year))
}

# Get last list of of the selected year
getHauls <- function(year = maxYear) {
  unique(parsedData[parsedData$Year==year,]$HaulNo)
}

# Helper function to choose the correct get haul function (above)
getHaulList <- function(haulSubsetType){
  if(haulSubsetType=="all")
    hauls <- getHauls() 
  if(haulSubsetType=="last"){
    hauls <- getLastHaul(maxYear)
  }
  return(hauls)
}

# Helper function to choose the available species based on the haul type
getSpeciesList <- function(haulSubsetType){
  print(haulSubsetType)
  if(haulSubsetType=="all")
    species <- unique(parsedData[parsedData$Year==maxYear,]$SpecCode) 
  if(haulSubsetType=="last"){
    # Get latest haul
    lastHaul <- getLastHaul(maxYear)
    species <- unique(parsedData[parsedData$Year==maxYear & parsedData$HaulNo==lastHaul,]$SpecCode)
  }
  return(species)
}


getCurrentStation <- function(year, haul) {
  if(length(haul)==0) return(NULL)
  stations <- unique(trimws(as.character(parsedData[parsedData$Year==year & parsedData$HaulNo==haul,]$StNo)))
  return(stations)
}

Brush_densityplot <- function(This_year, Fish_choice, Last_haul, fish_data){

  if(length(Last_haul)==0) return(NULL)
 
  print(This_year)
  print(Fish_choice)

  print(paste("ALast haul:", Last_haul))

  # Find the nearest hauls
  #xp <- unique(unlist(fish_data[fish_data$Year==This_year, "HaulNo"]))
  #if(Last_haul < min(xp)) Last_haul <- min(xp)
  #else if(Last_haul > max(xp)) Last_haul <- max(xp)
  #else Last_haul <- which.min(abs(xp - as.integer(Last_haul))) 
  
  print(paste("BLast haul:", Last_haul))

  Current_Station <- getCurrentStation(This_year, Last_haul)

  print(Current_Station)

  #Last Haul refers to the brush point from the K plot. 
density_histor <- fish_data %>% filter(Year != This_year)%>%
  filter(SpecCode == Fish_choice)%>% #Fish selection var,
  filter(StNo == Current_Station)#Current Station to match current haul location

density_histor <- as.data.frame(rep(density_histor$LngtClass, density_histor$HLNoAtLngt))
colnames(density_histor) <- "den_hist"

density_curr <- fish_data %>% filter(Year == This_year)%>%
  filter(SpecCode == Fish_choice)%>%
  filter(HaulNo == Last_haul)

density_curr <- as.data.frame(rep(density_curr$LngtClass, density_curr$HLNoAtLngt))
colnames(density_curr) <- "den_curr"


plotOut <- ggplot()+
  #historical density distribution for selected or last station
  geom_density(aes(x = den_hist),color = Hist_color, size = 2,data = density_histor )+
  #current density distribution for selected or last station 
  geom_density(aes(x = den_curr ), color = Current_color,size = 2,
                 alpha = 0.6, data = density_curr)+
  xlab(label = "Length Class (mm)")+
  theme_bw()

return(plotOut)

}

K_plot <- function(fish_data, Fish_choice, This_year, Button_choice){
#In the future this is where the AB table would be linked
A <- -5.446 # intercept
B <- 3.1818 #slope of the fit

#Calculates the estimated wieght for fish
fish_stats <- fish_data %>%
  filter(SpecCode == Fish_choice)%>%
  mutate(Pred_Wt = HLNoAtLngt * (exp(A)*(LngtClass/10)^B))%>%
  group_by(Year,HaulNo,CatIdentifier)%>%
  summarise(K = sum(Pred_Wt) - mean(SubWgt),
            Num_fish = sum(HLNoAtLngt)) 

fish_stat <- fish_stats %>% filter(Year != This_year)  

fish_mean <- mean(fish_stat$K,na.rm = TRUE)

fish_CI <- sd(fish_stat$K, na.rm = TRUE)

#Plot
plotOut <- ggplot()+
  geom_hline(aes(yintercept = fish_mean), color = "red", size = 2, alpha = 0.6)+
  geom_hline(aes(yintercept = fish_mean - fish_CI),
             color = "red", size = 2, alpha = 0.6, linetype = "dotted")+
  geom_hline(aes(yintercept = fish_mean + fish_CI),
             color = "red", size = 2, alpha = 0.6, linetype = "dotted")+
  geom_point(aes(x = HaulNo, y = K, size = Num_fish),shape = 21,
             alpha = 0.5,color = Hist_color,fill = Hist_color,
             data = fish_stats %>% filter(Year == This_year)%>%
               filter(!HaulNo %in% Button_choice))+
  geom_point(aes(x = HaulNo, y = K, size = Num_fish),shape = 21,
             alpha = 0.9, color = Current_color,fill = Current_color,
             data = fish_stats %>% filter(Year == This_year) %>%
               filter(HaulNo %in% Button_choice))+
  scale_size_continuous(range = c(0.5,16), breaks = seq(0,max(fish_stats$Num_fish),
                                                      by = 100),
                        name = "Fish (n)")+
  xlab(label = "Haul No")+
  theme_bw()+
  theme(axis.text = element_text(size = 14, color = "black"),
        axis.title = element_text(size = 14, color = "black"),
        legend.text = element_text(size = 14, color = "black"),
        legend.title = element_text(size = 14, color = "black"))
return(plotOut)

}

