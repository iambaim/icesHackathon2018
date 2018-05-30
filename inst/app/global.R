# Get Data
#dataInputFile <- "/home/user/Documents/IE_IGFS_LFs.csv"
dataInputFile <- system.file("extdata", "IE_IGFS_LFs.csv", package = "icesHackathon2018G3")
print(dataInputFile)
parsedData <- read.csv(dataInputFile)

# Assuming we operate on one haulSubsetType of quarters, cruise, ship, and countries
maxYear <- max(unique(parsedData$Year))

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


Brush_densityplot <- function(This_year, Fish_choice,Current_Station, Last_haul,fish_data){
  #Last Haul refers to the brush point from the K plot. 
density_histor <- fish_data %>% filter(Year != This_year)%>%
  filter(SpecCodeType == Fish_choice)%>% #Fish selection var,
  filter(StNo == Current_Station)#Current Station to match current haul location

density_histor <- as.data.frame(rep(density_histor$LngtClass, density_histor$HLNoAtLngt))
colnames(density_histor) <- "den_hist"

density_curr <- fish_data %>% filter(Year == This_year)%>%
  filter(SpecCodeType == Fish_choice)%>%
  filter(HaulNo == Last_haul)

density_curr <- as.data.frame(rep(density_curr$LngtClass, density_curr$HLNoAtLngt))
colnames(density_curr) <- "den_curr"


ggplot()+
  #historical density distribution for selected or last station
  geom_density(aes(x = den_hist),color = Hist_color, size = 2,data = density_histor )+
  #current density distribution for selected or last station 
  geom_density(aes(x = den_curr ), color = Current_color,size = 2,
                 alpha = 0.6, data = density_curr)+
  xlab(label = "Length Class (mm)")+
  theme_bw()

}
