require(dplyr)
require(ggplot2) # Plotting
allmatches <- read.csv("http://www.cvilletennis.org/catsdb.csv")
allmatches <- allmatches[ ,1:10]
allmatches["set1MOV"] <- NA
allmatches$set1MOV <- abs(allmatches$WinnerSet1 - allmatches$LoserSet1)
allmatches <- mutate(allmatches, set3Played = (WinnerSet3 > 0))
maptable = c("7-6", "Ambiguous", "6-4", "6-3", "6-2", "6-1")
allmatches$set1Score <- maptable[allmatches$set1MOV]

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
  if (allmatches[i, "set1Score"] == "Ambiguous") {
    if(allmatches[i, "WinnerSet1"] == 5 || allmatches[i, "WinnerSet1"] == 7) {
      allmatches[i, "set1Score"] = "7-5"
    } else {
      allmatches[i, "set1Score"] = "6-4"
    }
  }
}

shinyServer(
  function(input, output) {

    observeEvent(input$go, {
      rv <- reactiveValues(graphTitle = c("Match Results for Year ", input$year))
      rv$graphTitle<- paste("Match Results for First Set Winner in Year ", input$year)
      if (input$year == "All Years") {
        matchset = allmatches
        rv$graphTitle <- paste("Match Results for First Set Winner - All Years")
      } else {
        matchset <- filter(allmatches, year==input$year)
      }
      output$text1 <- renderText({c(nrow(matchset), " Total Matches")})
      ttl <- rv$graphTitle
      output$YearHist <- renderPlot( {
        ggplot(matchset, aes(x=set1MOV, colour=outcome)) +
          geom_histogram(fill="white", position="dodge", binwidth = 0.5) +
          ggtitle(rv$graphTitle) +
          xlab("1st Set Margin of Victory (Games)") +
          ylab("Count") +
          scale_x_continuous(breaks=seq(1,6,1))
      } )
      perOutcome <- matchset %>% group_by(set1MOV, outcome) %>% summarise(outcomes = n())
      colnames(perOutcome) <- c("First Set Margin of Victory", "Outcome", "Count")
      perOutcome["Percent"] <- NA
      for(i in 1:6) {
        subtotal <- perOutcome[3*(i-1)+1,3] + perOutcome[3*(i-1)+2,3] + perOutcome[3*(i-1)+3,3]
        for (j in 1:3) {
          perOutcome[3*(i-1)+j,4] <- 100.0 *perOutcome[3*(i-1)+j,3] / subtotal
        }
      }
      output$table1 <- renderTable( {perOutcome})
    } )
  }
)