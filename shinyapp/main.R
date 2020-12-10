library(shiny)
library(DMRcaller)
library(ggplot2)
source("ui.R")
source("server.R")


options(shiny.port = 8080)

shinyApp(ui, server)