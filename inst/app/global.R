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

