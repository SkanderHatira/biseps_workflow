library(shiny)
source("ui.R")
source("server.R")


options(shiny.port = 8080)

shinyApp(ui, server)
