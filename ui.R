# source code submitted to github at https://github.com/heatwolej/DataProducts
# shiny App deployed to https://jheatwole.shinyapps.io/ShinyTennis/
# R Presentation deployed to http://rpubs.com/heatwolej/183859

shinyUI(
  fluidPage(
    # Application title
    h2("CATS Tennis - First Set Winner and Match Results"),
    img(height = 179, width = 921, 
             src = "alt-tennis-court_2.gif"),
    hr(),
    p("In 2015, a statistical inference project was completed that demonstrated that those players who win the first set in a community tennis match by 4 games or more",
           "have a statistically more significant probability of winning the overall match when compared to first set winners by smaller margins.",  
           "Data for this study were collected for community tennis matches completed under the CATS organization. You can vistit the CATS website",
    a(href = "http://www.cvilletennis.org", "here."),
        "The study can be reviewed",
    a(href = "http://www.cvilletennis.org/RecreationalTennis.html", "here.")),
    p("This Shiny app provides users with a mechanism to visualize this data and judge whether the trend has changed over the organization's ten year history.",
        "Select a year (or 'All Years') in the drop-down box and click the Submit button. A histogram will be generated showing the frequency of various outcomes for each first set score for all matches played in that time period." ,   
        "The Shiny app generates a table beneath the histogram for those viewers who desire access to the actual values."),
    wellPanel(
      selectInput('year', 'Matches Played In', 
                  c("All Years",2006,2007,2008,2009,2010,2011,2012,2013,2014,2015),
                  selected = 2006, width='160px'), 
      actionButton(inputId = "go", label = "Submit")
    ),
    hr(),
    textOutput('text1'),
    tabsetPanel(type = "tabs",
                tabPanel("Histogram", plotOutput('YearHist')),
                tabPanel("Tabular Results", tableOutput('table1')),
                tabPanel("Raw Data", DT::dataTableOutput('table2'))),
    hr(),
    img(src = "tennis-ball-banner.gif")
  )

)