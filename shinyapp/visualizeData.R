visualizeData <- tabPanel("Visualize Data",fluid = TRUE ,
        fluidRow(
            fluidRow(
              column(3,
              fileInput("control", "Choose a control Methylation report",
                accept = c(".CX_report",".txt"))
              )
            ,
            column(3,
            textInput("control_label", "Control Label:")
            )
            ,
          column(3,
              fileInput("treatment", "Choose a treatment Methylation report",
                accept = c(".CX_report",".txt"))
          ),  
          column(3,
           textInput("treatment_label", "Treatment Label:")
          )   
           
                )),
        tabsetPanel(
            tabPanel("Compute DMR's",
                fluidRow(
                 column(
             2,
          selectInput("context", "Context:",
                c("CG" = "CG",
                  "CHG" = "CHG",
                  "CHH" = "CHH")),
            sliderInput("pvalue", "P-value:",
                min = 0, max = 1, value = 0.05,step = 0.05
            ),   
        selectInput("method", "Method:",
                c("Bins" = "bins",
                  "Neighbourhood" = "neighbourhood",
                  "Noise Filter" = "noise_filter")),   
                  numericInput("mincytosine", "minCytosinesCount:", 4, min = 0),
                   conditionalPanel(condition = "input.method == 'bins'",
                    numericInput("binSize", "binSize:", 1000, min = 0)
                  ),
                  selectInput("stat_test", "Statistical Test:",
                    c("Score" = "score",
                    "Fisher" = "fisher")),
                  numericInput("minGap", "minGap:", 200, min = 0),
                  numericInput("minSize", "minSize:", 50, min = 0),   
                  numericInput("minProportionDifference", "minProportionDifference:", 0.4, min = 0,max=1),
                  numericInput("minReadsPerCytosine", "minReadsPerCytosine:", 5, min = 0 ,max = 20),
                  numericInput("cores", "cores:", 6, min = 1 , max = 8)  ,
                  actionButton("goButton", "Compute DMR's" ,icon("refresh"))   
                    
      ) ,
    column(10 , 
      mainPanel(
        tableOutput("computeDMR"))
  
        )))
        ,
tabPanel("methylation profile",  
    fluidRow(
      column(
         2, 
        numericInput("plot_meth_windowSize", "Window Size:", 10000, min = 100),
        selectInput("plot_meth_context", "Context:",
                c("CG" = "CG",
                  "CHG" = "CHG",
                  "CHH" = "CHH")),
                  checkboxInput("plot_meth_autoScale", "Autoscale", FALSE),
                  actionButton("plot_meth_profile", "Plot Methylation Profile")
               ) 
               ,
        column(10 , 
             plotOutput("plot_methylarion_profile")
             )
             )
      ),
tabPanel("Data Coverage",  
    fluidRow(
      column(
         2, 
        selectInput("plot_coverage_context", "Context:",
                c("CG" = "CG",
                  "CHG" = "CHG",
                  "CHH" = "CHH")),
                  checkboxInput("plot_coverage_proportion", "Porportion", TRUE),
                  checkboxInput("plot_coverage_contextPerRow", "Context Per Row", FALSE),
                  actionButton("plot_coverage_profile", "Plot Data Coverage Profile")
               ) 
               ,
        column(10 , 
             plotOutput("plot_coverage")
             )
             )
      ) ,
  tabPanel("DMR's Distribution",  
    fluidRow(
      column(
         2, 
        sliderInput("plot_distribution_range", "Number of observations:",
            min = 0, max = 1000000, value = c(50000,600000),post = ","),
        numericInput("plot_distribution_windowSize", "Window Size:", 5000, min = 1000),
                  checkboxInput("plot_distribution_binary", "Binary", TRUE),
                  actionButton("plot_distribution", "Plot DMR's Distribution")
               ) 
               ,
        column(10 , 
             plotOutput("plot_distribution")
             )
             )
      )  
    
    
))


