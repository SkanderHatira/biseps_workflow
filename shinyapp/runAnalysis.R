runAnalysis <- tabPanel("Run Analysis", fluid = TRUE, 
            sidebarPanel(
                    titlePanel("Input Configuration"), 
                    fileInput("units", "Choose a Tab Seperated File describing your input Data", accept = c(".tsv")),
                    fileInput("samples", "Choose a Tab Seperated File describing your samples" , accept = c(".tsv")),
                    titlePanel("General Configuration"),
                     checkboxInput("trimming", "Quality check", FALSE),
        checkboxInput("genome_preparation", "Genome Preparation", FALSE),
        checkboxInput("methylation_extraction_bismark", "Methylation Extraction", FALSE),
        checkboxInput("methylation_calling", "Methylation Calling", FALSE),
        checkboxInput("quality", "Generate reports", FALSE),
       
        tags$span(title="Click here to launch the pipeline on subsampled data", actionButton("quickrun", "Quick Run")),
        tags$span(title="Click here to launch the pipeline on all the data",actionButton("fullrun", "Launch Analysis !"))
        ) ,

        mainPanel(
        conditionalPanel(
          tags$h4(tags$a("Trimmomatic Parameters" ,href="http://www.usadellab.org/cms/?page=trimmomatic",icon("cog", lib = "glyphicon"))),
              condition = "input.trimming == 1",
              inputPanel(
          textInput("trimmer", "Trimmer", "ILLUMINACLIP"),
          numericInput("trimMinLen", "Minimum length Reads:", 36, min = 0),
          textInput("trimming_extra", "Extra")
        )),
        conditionalPanel(
           tags$h4(tags$a("Genome Preparation Parameters" ,href="https://www.bioinformatics.babraham.ac.uk/projects/bismark/",icon("cog", lib = "glyphicon"))),
              condition = "input.genome_preparation == 1",
            inputPanel(
              textInput("genome_preparation_extra", "Extra"))
        ),
        conditionalPanel(
          tags$h4(tags$a("Alignment Parameters" ,href="https://www.bioinformatics.babraham.ac.uk/projects/bismark/",icon("cog", lib = "glyphicon"))),
              condition = "input.methylation_extraction_bismark == 1",
              inputPanel(
              selectInput(
                "aligner", "Aligner",
                c("bowtie2", "hisat2")),
              tags$span(title="Set the number of allowed mismatches",
              numericInput("N", "Number of mismatches", 0, min = 0,max=1)),
              tags$span(title="Set the size of Kmer",
              numericInput("L", "Size of seed", 20, min = 20,max=35)),
              tags$span(title="Set the number of alignment instances to spawn, speed increases nearly linearly for every instance ;
               Note: One instance requires 4 cores",
              numericInput("instances", "Number of aligner instances", 1, min = 1,max=6)),
              textInput("aligner_options", "Extra"))
              

              ),
        conditionalPanel(
          tags$h4(tags$a("Methylation Calling Parameters" ,href="https://www.bioinformatics.babraham.ac.uk/projects/bismark/",icon("cog", lib = "glyphicon"))),
              condition = "input.methylation_calling == 1",
              inputPanel(
              textInput("methylation_calling", "Extra"))
              ),
        conditionalPanel(
          tags$h4(tags$a("Generating Reports Parameters" ,href="https://www.bioinformatics.babraham.ac.uk/projects/bismark/",icon("cog", lib = "glyphicon"))),
            condition = "input.quality == 1",
            inputPanel(
            textInput("Reports Options", "Extra"))
        )
        ))