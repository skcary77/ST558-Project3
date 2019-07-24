library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)

#source("global.R",local=TRUE)
#runGitHub("ST558-Project3", "skcary77")

games <- read_csv("gameSales.csv")
games$Year_of_Release <- as.numeric(games$Year_of_Release)
games$User_Score <- as.numeric(games$User_Score) * 10
nrow(games)
games <- games[complete.cases(games), ]
#any publishers with less than 200 games should be modeled as 'other'
pubCount <- as.data.frame(table(games$Publisher),stringsAsFactors = FALSE) %>% 
        dplyr::filter(Freq >= 200) %>% select(Var1)
#probably exclude Developer and Game Name from prediction set
games$Publisher <- if_else(games$Publisher %in% pubCount$Var1,games$Publisher,"Other")
games <- games[,!(names(games) %in% c("NA_Sales","EU_Sales","JP_Sales","Other_Sales","Developer"))]


shinyServer(function(input, output, session) {

        myData <- reactive({
                games[games[,input$scatterVar] >= input$scoreRange[1] &
                              games[,input$scatterVar] <= input$scoreRange[2]        
                      ,]
        })
        
        output$ex1 <- renderUI({
                withMathJax(helpText('Dynamic output 1:  $$\\alpha^2$$'))
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
        
        #regression prediction
        myLMPred <- reactive({
                lmReact <- myLM()
                predDF <- myPredDF()
                predOut <- predict(lmReact,newdata = predDF)
        })
        
        #K nearest neighbor
        myKNNFit <- reactive({
                gamesknn <- games[,c("Global_Sales","Year_of_Release","Critic_Score","Critic_Count","User_Score","User_Count")]
                predDF <- myPredDF()
                predDF <- predDF[,c("Year_of_Release","Critic_Score","Critic_Count","User_Score","User_Count")]
                knnFit <- FNN::knn.reg(train=gamesknn[,-1],y=gamesknn$Global_Sales,k=input$predNeighbors)
                knnFit$R2Pred
        })
        
        myKNNPred <- reactive({
                gamesknn <- games[,c("Global_Sales","Year_of_Release","Critic_Score","Critic_Count","User_Score","User_Count")]
                predDF <- myPredDF()
                predDF <- predDF[,c("Year_of_Release","Critic_Score","Critic_Count","User_Score","User_Count")]
                knnPred <- FNN::knn.reg(train=gamesknn[,-1],test=predDF,y=gamesknn$Global_Sales,k=input$predNeighbors)
                knnPred$pred
        })
        
        #Unsupervised learning
        myPC <- reactive({
                #only using numeric columns
                pcDF <- games[,c("Year_of_Release","Critic_Score","Critic_Count","User_Score","User_Count")]
                pc <- prcomp(pcDF,center=input$pcCenter, scale = input$pcScale)
        })
        
        #create text info
        output$lmSummary <- renderPrint({
                lmReact <- myLM()
                summary(lmReact)
        })
        output$lmPred <- renderPrint({
                print(myLMPred())
        })
        
        #knn output
        output$knnR2 <- renderPrint({
                print(myKNNFit())
        })
        output$knnPred <- renderPrint({
                print(myKNNPred())
        })
        
        #principal component output
        #https://cran.r-project.org/web/packages/ggfortify/vignettes/plot_pca.html
        output$biplot <- renderPlot({
                biplot(myPC(), xlabs = rep(".", nrow(games)), cex = 1.2)
        })
        
        
        

        
})
