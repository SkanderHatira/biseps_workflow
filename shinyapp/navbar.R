source("runAnalysis.R")
source("visualizeData.R")
source("userGuide.R")

navbar <- navbarPage("BiSSProP -beta-" ,
    runAnalysis ,
    visualizeData ,
    userGuide
)