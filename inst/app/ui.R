# Define UI ----
ui <- fluidPage(
  titlePanel("QC Tool"),
  sidebarLayout(
    sidebarPanel(
      titlePanel("Controls"),
      helpText("Select the required parameters"),
      uiOutput("choose_haulSubset"),
      uiOutput("choose_species"),
      helpText(paste("We are operating on cruise year", maxYear)),
      uiOutput("list_hauls") 
    ),
    mainPanel(
      titlePanel("Main Panel")
    )
  )
)

