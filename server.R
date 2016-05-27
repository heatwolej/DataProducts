require(dplyr)
require(ggplot2) # Plotting
require(DT)

## Read prepared csv file from CATS website, add useful columns
allmatches <- read.csv("http://www.cvilletennis.org/catsdb.csv")
allmatches <- allmatches[ ,1:10]
allmatches["set1MOV"] <- NA
allmatches$set1MOV <- abs(allmatches$WinnerSet1 - allmatches$LoserSet1)
allmatches <- mutate(allmatches, set3Played = (WinnerSet3 > 0))

# set outcome column for histogram display
for (i in 1:nrow(allmatches)) {
  if (allmatches[i, "set3Played"] == FALSE) {
    allmatches[i, "outcome"] <- "Won in 2 sets"
  }
  else if (allmatches[i,"A.or.B"] == "A") {
    allmatches[i, "outcome"] <- "Won in 3 sets"
  }
  else {
    allmatches[i, "outcome"] <- "Lost in 3 sets"
  }
  allmatches[i, "year"] <- floor(allmatches[i, "TimeID"]/10)
}

shinyServer(
  function(input, output) {

    observeEvent(input$go, {
      rv <- reactiveValues(graphTitle = c("Match Results for Year ", input$year))
      rv$graphTitle<- paste("Match Results for First Set Winner in Year ", input$year)
      
      ## set Graph Title and filter Data set
      if (input$year == "All Years") {
        matchset = allmatches
        rv$graphTitle <- paste("Match Results for First Set Winner - All Years")
      } else {
        matchset <- filter(allmatches, year==input$year)
      }
      output$text1 <- renderText({c(nrow(matchset), " Total Matches")})
      output$YearHist <- renderPlot( {
        ggplot(matchset, aes(x=set1MOV, colour=outcome)) +
          geom_histogram(fill="white", position="dodge", binwidth = 0.5) +
          ggtitle(rv$graphTitle) +
          xlab("1st Set Margin of Victory (Games)") +
          ylab("Count") +
          scale_x_continuous(breaks=seq(1,6,1))
      } )
      ## prepare subtotals for table display
      perOutcome <- matchset %>% group_by(set1MOV, outcome) %>% summarise(outcomes = n())
      colnames(perOutcome) <- c("First Set Margin of Victory", "Outcome", "Count")
      
      ## manually calculate percentage column for table display
      perOutcome["Percent"] <- NA
      for(i in 1:6) {
        subtotal <- perOutcome[3*(i-1)+1,3] + perOutcome[3*(i-1)+2,3] + perOutcome[3*(i-1)+3,3]
        for (j in 1:3) {
          perOutcome[3*(i-1)+j,4] <- 100.0 *perOutcome[3*(i-1)+j,3] / subtotal
        }
      }
      output$table1 <- renderTable( {perOutcome})
      output$table2 <- DT::renderDataTable(
        DT::datatable(matchset, options = list(pageLength = 25))
      )    
      
    } )
  }
)