library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(ggfortify)
library(DT)
library(shinycssloaders)

source("global.R",local=TRUE)
numericCols <- c("Year_of_Release","Critic_Score","Critic_Count","User_Score","User_Count")
#runGitHub("ST558-Project3", "skcary77")

shinyServer(function(input, output, session) {
    
#DATA EXPLORATION===================================================================
    #scatterplot should reflect values the user selects
    myData <- reactive({
        games[games[,input$scatterVar] >= input$scoreRange[1] &
                  games[,input$scatterVar] <= input$scoreRange[2]        
              ,]
    })

    #create scatterplot
    output$scatterPlot <- renderPlotly({       
        newData <- myData()
        g <- ggplot(newData, aes_string(x = input$scatterVar, y = "Global_Sales"))
        g + geom_point(aes_string(col =input$scatterColor))
    })

    #create frequency table
    output$table <- renderTable({
        newData <- myData() 
        table(newData[,input$countVar])
    },colnames = FALSE)
#DATA EXPLORATION===================================================================
    
#LINEAR REGRESSION==================================================================
    
    #fit the linear regression
    myLM <- reactive({
        if(length(input$lmPredictors) == 0) return(NULL)
        outcome <- "Global_Sales"
        lmVariables <- input$lmPredictors
        lmFormula <- as.formula(
            paste(outcome, 
                  paste(lmVariables, collapse = " + "), 
                  sep = " ~ "))
        lmFit <- lm(lmFormula, data = games) #use full data set for training
    })
    
    #create prediction data frame from user input
    myPredDF <- reactive({
        data.frame(
            Platform = input$predPlatform,
            Year_of_Release = input$predYear,
            Genre = input$predGenre,
            Publisher = input$predPublisher,
            Critic_Score = input$predCriticScore,
            Critic_Count = input$predCriticCount,
            User_Score = input$predUserScore,
            User_Count = input$predUserCount,
            Rating = input$predRating)  
    })
    
    #store prediction based on user selection
    myLMPred <- reactive({
        if(length(input$lmPredictors) == 0) return(NULL)
        lmReact <- myLM()
        predDF <- myPredDF()
        predOut <- predict(lmReact,newdata = predDF)
    })
#LINEAR REGRESSION==================================================================
    
#K nearest neighbor=================================================================
    
    #fit KNN (can only use numberic columns) based on user selected number of neighbors
    #keep the R-squared
    myKNNFit <- reactive({
        gamesknn <- games[,c("Global_Sales",numericCols)]
        knnFit <- FNN::knn.reg(train=gamesknn[,-1],y=gamesknn$Global_Sales,k=input$predNeighbors)
        knnFit$R2Pred
    })
    
    #create prediction from KNN, only using numeric columns
    myKNNPred <- reactive({
        gamesknn <- games[,c("Global_Sales",numericCols)]
        predDF <- myPredDF()
        predDF <- predDF[,numericCols]
        knnPred <- FNN::knn.reg(train=gamesknn[,-1],test=predDF,y=gamesknn$Global_Sales,k=input$predNeighbors)
        knnPred$pred
    })
    

#K nearest neighbor=================================================================
    
#SUPERVISED LEARNING OUTPUT=========================================================
    output$lmSummary <- renderPrint({
        lmReact <- myLM()
        if(is.null(lmReact)) return("Must select at least one predictor for Linear Regression Model Summary")
        summary(lmReact)
    })

    output$lmCompare <- renderText({
        if(is.null(myLM())) return(HTML("Must select at least one predictor for R-squared Comparison"))
        lmReact <- summary(myLM())
        lmR2 <- lmReact$r.squared
        lmAdjR2 <- lmReact$adj.r.squared
        knnR2 <- myKNNFit()
        HTML(
            paste0("Your linear regression has a R-squared of <b><u>",
                   round(lmR2,4),
                   "</b></u> (",round(lmAdjR2,4)," Adjusted R-squared), compared to a R-squared of <b><u>",
                   round(knnR2,4),"</b></u> for the KNN model")
        )
        
    })
    
    output$knnR2 <- renderPrint({
        print(myKNNFit())
    })

    output$predictionCompare <- renderText({
        lmPred <- myLMPred()
        knnPred <- myKNNPred()
        if(is.null(lmPred)) return(HTML("Must select at least one predictor for Linear Regression Prediction")) 
        HTML(
            paste0("Your linear regression predicts global sales of <b><u>",
                   round(lmPred,1),
                   "</b></u> million units, compared to <b><u>",
                   round(knnPred,1),"</b></u> million units for the KNN model. The average of the two models is <b><u>",
                   round((lmPred + knnPred)/2,1), "</b></u> million units" )
        )
    })

#SUPERVISED LEARNING OUTPUT=========================================================     
    
#Unsupervised learning==============================================================
    
    #create PCA using only numeric columns
    myPC <- reactive({
        pcDF <- games[,numericCols]
        pc <- prcomp(pcDF,center=input$pcCenter, scale = input$pcScale)
    })

    #create PCA biplot
    output$plotlybiplot <- renderPlotly({
        autoplot(myPC(), data = games, colour = input$pcColor,
                 loadings = TRUE, loadings.colour = 'blue',
                 loadings.label = TRUE, loadings.label.size = 3,size=0.5)
    })
#Unsupervised learning==============================================================    
    
#VIEW DATA==========================================================================
    output$DTtable <- DT::renderDataTable(
        DT::datatable({
            data <- games
            if (input$dtGenre != "All") {
                data <- data[data$Genre == input$dtGenre,]
            }
            if (input$dtPlatform != "All") {
                data <- data[data$Platform == input$dtPlatform,]
            }
            if (input$dtPublisher != "All") {
                data <- data[data$Publisher == input$dtPublisher,]
            }
            if (input$dtRating != "All") {
                data <- data[data$Rating == input$dtRating,]
            }
            data
        },
        extensions = 'Buttons',
        options = list(dom = 'Bfrtip',buttons = c('copy', 'csv'))
        )
    )
#VIEW DATA==========================================================================
    
    
})
