library(markdown)

shinyUI(navbarPage("Stochastic Threshold Calculator",
         tabPanel("Load Data",
                  sidebarLayout(
                    sidebarPanel(
                      fileInput('file1', 'Choose CSV File',
                                accept=c('text/csv', 
                                         'text/comma-separated-values,text/plain', 
                                         '.csv')),
                      tags$hr(),
                      checkboxInput('header', 'Header', TRUE),
                      radioButtons('sep', 'Separator',
                                   c(Comma=',',
                                     Semicolon=';',
                                     Tab='\t'),
                                   ',')
                    ),
                    mainPanel(
                      tabsetPanel(
                        tabPanel('File Format',
                                 includeMarkdown("instructions.Rmd")
                        ),
                        tabPanel("File Contents",
                          tableOutput('contents')
                        )
                      )
                    )
                  )
         ),
         tabPanel("Logistic Regression",
                  sidebarLayout(
                    sidebarPanel(
                      selectInput('aphColName', 'Average Peak Height Variable', NULL),
                      numericInput('dropThresh', 'Dropout Threshold', 25,
                                   min = 1, max = 150),
                      selectInput('missVal', 'Missing value code', c('0',NA)),
                      checkboxInput('weightReg', 'Weight regression', value = TRUE),
                      numericInput('alphaVal', HTML("&alpha;:"), min = 0.001, max = 0.1, value = 0.001, step = 0.001)
                    ),
                    mainPanel(
                      plotOutput('plot1')
                    )
                  )
         ),
         tabPanel("About",
                      fluidRow(
                               column(6,
                                      includeMarkdown("about.md")
                               ),
                               column(3,
                                      img(class="img-polaroid",
                                          src=paste0("http://www.stats.org.nz/Newsletter73/images/JamesCurran.JPG"))
                               )
                             )
                    )
         )
)

