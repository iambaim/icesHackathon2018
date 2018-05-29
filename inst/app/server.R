# Define server logic ----
server <- function(input, output) {
  getSpecies <- function(haulSubsetType="lenWt"){
         if(is.null(input[["haulSubset"]]))
	   return(list("None"))
         else
	   return(as.list(getSpeciesList(input[["haulSubset"]])))
  }
  # Radio button for the type of haul subset
  output$choose_haulSubset <- renderUI({
       radioButtons("haulSubset", "Choose one:",
               choiceNames = list(
                 "Last haul",
                 "All hauls"
               ),
               choiceValues = list(
                 "last", "all"
               ))
  })
  # Drop-down selection box for which data set
  output$choose_species <- renderUI({
      selectInput("species", "Species", choices=getSpecies("lenWt"), selected=1)
  })
  # Print out Hauls involved
  output$list_hauls <- renderUI({
      if(is.null(input[["haulSubset"]]))
        helpText("")
      else
        helpText(paste("Haul(s) involved are:", toString(getHaulList(input[["haulSubset"]]))))
  })
}

