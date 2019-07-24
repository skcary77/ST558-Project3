library(tidyverse)
library(shiny)
library(plotly)

#allow users to create table by categorical variables
catVars <- c("Platform","Year_of_Release","Genre","Publisher","Developer","Rating")
#allow users to change scatter plot x-variable
scatterX <- c("Critic_Score","User_Score")
#allow users to select predictors
predPlatform <- c("Wii","DS", "X360","PS3","PS2","3DS","PS4","PS",
                  "XB","PC","PSP","WiiU","GC","GBA","XOne", "PSV",  "DC")
predGenre <- c("Sports","Racing","Platform","Misc","Action","Puzzle",     
               "Shooter","Fighting","Simulation","Role-Playing","Adventure","Strategy")
predPublisher <- c("Activision","Electronic Arts","Konami Digital Entertainment","Namco Bandai Games","Nintendo","Other","Sega","Sony Computer Entertainment","Take-Two Interactive","THQ","Ubisoft")
predRating <- c("AO","E","E10+","K-A","M","RP","T")


#https://datascience-enthusiast.com/R/shiny_ML.html
#https://shiny.rstudio.com/articles/layout-guide.html 

shinyUI(
        # Create a bootstrap fluid layout
        fluidPage(
                navbarPage("Video Game App",
                           tabPanel("Overview",
                                    HTML("Welcome to the Economic Analysis Shiny App."),
                                    br(),
                                    withMathJax("$x = 2$"),
                                    withMathJax(helpText('Dynamic output 1:  $$\\alpha^2$$'))
                                    #withMathJax(includeMarkdown('mathJax.Rmd'))
                                    
                                    
                           ),
                           tabPanel("Data Exploration",
                                    sidebarLayout(
                                            sidebarPanel(
                                                    selectizeInput("scatterVar", "Select Scatterplot X axis:", selected = "Critic_score", choices = scatterX),
                                                    br(),
                                                    selectizeInput("scatterColor", "Select Scatterplot Color:", selected = "Rating", choices = c("Platform","Year_of_Release","Genre","Rating")),
                                                    br(),
                                                    selectizeInput("countVar", "Select variable to count:", selected = "Rating", choices = catVars),
                                                    br(),
                                                    sliderInput("scoreRange", "ScoreRange",
                                                                min = 0, max = 100, value = c(0,100), step = 10)
                                            ),
                                            
                                            # Show output
                                            mainPanel(
                                                    #plotOutput("scatterPlot"),
                                                    plotlyOutput("scatterPlot"),
                                                    tableOutput("table")
                                            )
                                    )
                                    
                           ),
                           
                           tabPanel("Clustering",
                                    HTML("Blank")
                           ),
                           
                           navbarMenu("Modeling",
                                      tabPanel("Supervised Learning",
                                               sidebarLayout(
                                                       sidebarPanel(
                                                               selectInput("lmPredictors", "Select variables to include", choices = c("Platform","Year_of_Release","Genre","Publisher","Critic_Score","User_Score","Rating"),multiple=TRUE),
                                                               br(),
                                                               HTML("Create prediction by chaning variables below"),
                                                               selectizeInput("predPlatform", "Platform", selected = predPlatform[1], choices = predPlatform),
                                                               sliderInput("predYear", "Year of Release",
                                                                           min = 1980, max = 2030, value = 2019, step = 1,sep = ""),
                                                               selectizeInput("predGenre", "Genre", selected = predGenre[1], choices = predGenre),
                                                               selectizeInput("predPublisher", "Publisher", selected = predPublisher[1], choices = predPublisher),
                                                               sliderInput("predCriticScore", "Critic Score",
                                                                           min = 0, max = 100, value = 50, step = 1),
                                                               sliderInput("predCriticCount", "Critic Count",
                                                                           min = 0, max = 200, value = 30, step = 10),
                                                               sliderInput("predUserScore", "User Score",
                                                                           min = 0, max = 100, value = 50, step = 1),
                                                               sliderInput("predUserCount", "User Score",
                                                                           min = 0, max = 15000, value = 200, step = 100),
                                                               selectizeInput("predRating", "Rating", selected = predRating[1], choices = predRating),
                                                               br(),
                                                               br(),
                                                               br(),
                                                               "Test",
                                                               sliderInput("predNeighbors", "K Neighbors",
                                                                           min = 1, max = 100, value = 10, step = 1)
                                                               
                                                       ),
                                                       
                                                       # Show output
                                                       mainPanel(
                                                               #plotOutput("lmFit"),
                                                               verbatimTextOutput("lmSummary"),
                                                               verbatimTextOutput("lmPred"),
                                                               br(),
                                                               verbatimTextOutput("knnR2"),
                                                               verbatimTextOutput("knnPred")
                                                       )
                                               ) 
                                      ),
                                      tabPanel("K Nearest Neighbor",
                                               sidebarLayout(
                                                       sidebarPanel(
                                       br()
                                                       ),
                                                       
                                                       # Show output
                                                       mainPanel(
                                                               uiOutput('ex1')
                                                       )
                                               ) 
                                      ),
                                      
                                      
                                      tabPanel("Unsupervised Learning",
                                               sidebarLayout(
                                                       sidebarPanel(
                                                               checkboxInput("pcCenter", "Center Data",value=TRUE),
                                                               checkboxInput("pcScale", "Scale Data",value = TRUE)
                                                       ),

                                                       #Show output
                                                       mainPanel(
                                                               plotOutput("biplot")
                                                       )
                                               ) 
                                      )
                                      
                           )
                )
        )
)


