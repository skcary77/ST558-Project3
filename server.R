library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)

#source("global.R",local=TRUE)

games <- read_csv("gameSales.csv")
games$Year_of_Release <- as.numeric(games$Year_of_Release)
games$User_Score <- as.numeric(games$User_Score) * 10
nrow(games)
games <- games[complete.cases(games), ]
games <- games[,!(names(games) %in% c("NA_Sales","EU_Sales","JP_Sales","Other_Sales"))]

shinyServer(function(input, output, session) {

        myData <- reactive({
                games[games[,input$scatterVar] >= input$scoreRange[1] &
                              games[,input$scatterVar] <= input$scoreRange[2]        
                      ,]
        })
        
        #create plot
        #output$scatterPlot <- renderPlot({
        output$scatterPlot <- renderPlotly({       
                
                newData <- myData()
                g <- ggplot(newData, aes_string(x = input$scatterVar, y = "Global_Sales"))
                g + geom_point(aes_string(col =input$scatterColor))
        
        })
        
        
        
        
        # 
        # #create text info
        # output$info <- renderText({
        #         newData <- myData()
        #         paste("The average body weight for order", input$vore, "is", round(mean(newData$bodywt, na.rm = TRUE), 2), "and the average total sleep time is", round(mean(newData$sleep_total, na.rm = TRUE), 2), sep = " ")
        # })
        # 
        #create output of observations
        output$table <- renderTable({
                newData <- myData() 
                table(newData[,input$countVar])
        })
        
        #LINEAR REGRESSION
        myLM <- reactive({
        outcome <- "Global_Sales"
        lmVariables <- input$lmPredictors
        lmFormula <- as.formula(
                paste(outcome, 
                      paste(lmVariables, collapse = " + "), 
                      sep = " ~ "))
        lmFit <- lm(lmFormula, data = games)
        })
        
        #create text info
        output$lmSummary <- renderPrint({
                lmReact <- myLM()
                summary(lmReact)
        })

        
})
