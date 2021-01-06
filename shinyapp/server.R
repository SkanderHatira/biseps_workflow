server <- function(input, output) {
    options(shiny.maxRequestSize = 3000*1024^2)
    control <-  reactive({
        readBismark(input$control$datapath)
    })
    treatment <-  reactive({
        readBismark(input$treatment$datapath)
    })
    ComputedDMR <- reactive({
        computeDMRs(control(),
        treatment(),
        context = input$context,
        method = input$method,
        binSize = input$binSize,
        test = input$stat_test,
        pValueThreshold = input$pvalue,
        minCytosinesCount = input$mincytosine ,
        minProportionDifference = input$minProportionDifference,
        minGap = input$minGap,
        minSize = input$minSize,
        minReadsPerCytosine = input$minReadsPerCytosine,
        cores = input$cores) 
    })
    observeEvent(input$goButton, {

    output$computeDMR <- renderTable({ 
    if (is.null(input$control) | is.null(input$treatment))
      return(NULL)
    ComputedDMR()  
  })  
    
    })
    observeEvent(input$quickrun ,{
        system('docker run  --mount type=bind,src=/home/shatira/mnt/local_workflows/shiny-app/.test,dst=/BiSSProP/.test,readonly \\
      --mount type=bind,src="$(pwd)/docker-out/logs",dst=/BiSSProP/logs \\
      --mount type=bind,src="$(pwd)/docker-out/resources",dst=/BiSSProP/resources \\
      --mount type=bind,src="$(pwd)/docker-out/.snakemake",dst=/BiSSProP/.snakemake \\
      --mount type=bind,src="$(pwd)/docker-out/results",dst=/BiSSProP/results \\
      --mount type=bind,src="$(pwd)/.test/config/",dst=/BiSSProP/config bissprop --configfile config/config.yaml -n ', wait=FALSE)
        showModal(modalDialog(
        title = "Task Failed Successfully!",
        "Le pipeline a été lancé en mode rapide ",
        easyClose = TRUE,
        footer = NULL
      ))
    })
    observeEvent(input$plot_meth_profile,{
        if (is.null(input$control) | is.null(input$treatment))
            return(NULL)
        output$plot_methylarion_profile <- renderPlot({
        plotMethylationProfileFromData(control(),
            treatment(),
            conditionsNames = c(input$control_label,input$treatment_label),
            windowSize = input$plot_meth_windowSize,
            autoscale = input$plot_meth_autoScale,
            context = input$plot_meth_context)
        }) 

  }) 
      observeEvent(input$plot_coverage_profile,{
        if (is.null(input$control) | is.null(input$treatment))
            return(NULL)
        output$plot_coverage <- renderPlot({
        plotMethylationDataCoverage(control(),
            treatment(),
            breaks = c(1,5,10,15),
            regions = NULL,
            conditionsNames= c(input$control_label,input$treatment_label),
            context = input$plot_coverage_context,
            proportion = input$plot_coverage_proportion,
            labels=LETTERS,
            contextPerRow = input$plot_coverage_contextPerRow)
        }) 

  }) 

      observeEvent(input$plot_distribution,{
        if (is.null(input$control) | is.null(input$treatment))
            return(NULL)
        chr_local <- GRanges(seqnames = Rle("Chr3"), ranges =
        IRanges(input$plot_distribution_range[1],input$plot_distribution_range[2]))
        hotspots <- computeOverlapProfile(ComputedDMR(), chr_local,
        windowSize=input$plot_distribution_windowSize, binary=input$plot_distribution_binary)
        output$plot_distribution <- renderPlot({
            plotOverlapProfile(GRangesList("Chr3"=hotspots))
        }) 

  }) 
  observeEvent(input$fullrun, {
      system('docker run  --mount type=bind,src=/home/shatira/mnt/local_workflows/shiny-app/.test,dst=/BiSSProP/.test,readonly \\
      --mount type=bind,src="$(pwd)/docker-out/logs",dst=/BiSSProP/logs \\
      --mount type=bind,src="$(pwd)/docker-out/resources",dst=/BiSSProP/resources \\
      --mount type=bind,src="$(pwd)/docker-out/.snakemake",dst=/BiSSProP/.snakemake \\
      --mount type=bind,src="$(pwd)/docker-out/results",dst=/BiSSProP/results \\
      --mount type=bind,src="$(pwd)/.test/config/",dst=/BiSSProP/config bissprop --configfile config/config.yaml --cores 6 --use-conda -k ', wait=FALSE)
      showModal(modalDialog(
        title = "Task Failed Successfully!",
        "Le pipeline a bien été lancé tkt :D ",
        easyClose = TRUE,
        footer = NULL
      ))
    })
}
