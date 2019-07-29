library(tidyverse)
library(shiny)
library(plotly)
library(DT)
library(shinycssloaders)

#define lookup fields we will use for UI aspects
#======================================================================
#allow users to create table by categorical variables
catVars <- c("Platform","Year_of_Release","Genre","Publisher","Rating")

#allow users to change scatter plot
scatterX <- c("Critic_Score","User_Score")
scatterColor <- c("Platform","Year_of_Release","Genre","Rating")

#allow users to select regression predictors
regressionChoices <- c("Platform","Year_of_Release","Genre","Publisher",
                       "Critic_Score","User_Score","Rating")
#allow users to select predictors
predPlatform <- c("Wii","DS", "X360","PS3","PS2","3DS","PS4","PS",
                  "XB","PC","PSP","WiiU","GC","GBA","XOne", "PSV",  "DC")
predGenre <- c("Sports","Racing","Platform","Misc","Action","Puzzle",     
               "Shooter","Fighting","Simulation","Role-Playing","Adventure","Strategy")
predPublisher <- c("Activision","Electronic Arts","Konami Digital Entertainment",
                   "Namco Bandai Games","Nintendo","Other","Sega",
                   "Sony Computer Entertainment","Take-Two Interactive","THQ","Ubisoft")
predRating <- c("AO","E","E10+","K-A","M","RP","T")
#======================================================================

#https://datascience-enthusiast.com/R/shiny_ML.html
#https://shiny.rstudio.com/articles/layout-guide.html 

shinyUI(
    fluidPage(
        navbarPage("Video Game App",
                   tabPanel("Overview",
                            withMathJax(includeMarkdown('overview.Rmd'))
                   ),
                   tabPanel("Data Exploration",
                            sidebarLayout(
                                sidebarPanel(
                                    selectizeInput("scatterVar", 
                                                   "Scatterplot X Axis", 
                                                   selected = "Critic_score", 
                                                   choices = scatterX),
                                    selectizeInput("scatterColor", 
                                                   "Scatterplot Color",
                                                   selected = "Rating",
                                                   choices = scatterColor),
                                    sliderInput("scoreRange", 
                                                "Scatterplot Score Range",
                                                min = 0, max = 100, 
                                                value = c(0,100), 
                                                step = 10),
                                    br(),
                                    selectizeInput("countVar",
                                                   "Frequency table variable",
                                                   selected = "Rating", 
                                                   choices = catVars)
                                ),
                                mainPanel(
                                    h3("Scatterplot"),
                                    withSpinner(plotlyOutput("scatterPlot"),type=7),
                                    br(),
                                    br(),
                                    h3("Frequency Table"),
                                    withSpinner(tableOutput("table"),type=7)
                                )
                            )
                            
                   ),
                   navbarMenu("Modeling",
                              tabPanel("Supervised Learning",
                                       sidebarLayout(
                                           sidebarPanel(
                                               h4("Model inputs"),
                                               br(),
                                               selectInput("lmPredictors", 
                                                           "Linear Regression Variables",
                                                           selected = c("Critic_Score","User_Score","Genre"),
                                                           choices = regressionChoices,multiple=TRUE),
                                               sliderInput("predNeighbors", "K Neighbors",
                                                           min = 1, max = 100,
                                                           value = 10, 
                                                           step = 1),
                                               br(),
                                               br(),
                                               h4("Create prediction by chaning variables below"),
                                               selectizeInput("predPlatform",
                                                              "Platform", 
                                                              selected = predPlatform[1],
                                                              choices = predPlatform),
                                               sliderInput("predYear", 
                                                           "Year of Release",
                                                           min = 1980, max = 2030,
                                                           value = 2019, 
                                                           step = 1,
                                                           sep = ""),
                                               selectizeInput("predGenre",
                                                              "Genre",
                                                              selected = predGenre[1],
                                                              choices = predGenre),
                                               selectizeInput("predPublisher",
                                                              "Publisher",
                                                              selected = predPublisher[1],
                                                              choices = predPublisher),
                                               sliderInput("predCriticScore",
                                                           "Critic Score",
                                                           min = 0, max = 100,
                                                           value = 50,
                                                           step = 1),
                                               sliderInput("predCriticCount",
                                                           "Critic Count",
                                                           min = 0, max = 200,
                                                           value = 30,
                                                           step = 10),
                                               sliderInput("predUserScore",
                                                           "User Score",
                                                           min = 0, max = 100,
                                                           value = 50,
                                                           step = 1),
                                               sliderInput("predUserCount",
                                                           "User Score",
                                                           min = 0, max = 15000,
                                                           value = 200,
                                                           step = 100),
                                               selectizeInput("predRating",
                                                              "Rating",
                                                              selected = predRating[1],
                                                              choices = predRating)
                                               
                                           ),
                                           mainPanel(
                                               h4("Linear Regression Model Summary"),
                                               verbatimTextOutput("lmSummary"),
                                               h4("Model R-squared Comparison"),
                                               htmlOutput("lmCompare"),
                                               h4("Model Prediction Comparison"),
                                               htmlOutput("predictionCompare")
                                           )
                                       ) 
                              ),
                              tabPanel("Unsupervised Learning",
                                       sidebarLayout(
                                           sidebarPanel(
                                               h4("Center/Scale Data"),
                                               checkboxInput("pcCenter",
                                                             "Center Data",
                                                             value=TRUE),
                                               checkboxInput("pcScale",
                                                             "Scale Data",
                                                             value = TRUE),
                                               selectizeInput("pcColor",
                                                              "Color Variable",
                                                              selected = "Rating",
                                                              choices = c("Platform","Genre","Rating"))
                                               
                                           ),
                                           mainPanel(
                                               withSpinner(plotlyOutput("plotlybiplot"),type=7)
                                           )
                                       ) 
                              )
                   ),
                   tabPanel("View Data",
                            sidebarLayout(
                                sidebarPanel(
                                    selectizeInput("dtPlatform",
                                                   "Platform",
                                                   selected = "All",
                                                   choices = c("All",predPlatform)),
                                    selectizeInput("dtGenre",
                                                   "Genre",
                                                   selected = "All",
                                                   choices = c("All",predGenre)),
                                    selectizeInput("dtPublisher",
                                                   "Publisher",
                                                   selected = "All",
                                                   choices = c("All",predPublisher)),
                                    selectizeInput("dtRating",
                                                   "Rating",
                                                   selected = "All",
                                                   choices = c("All",predRating))
                                ),
                                mainPanel(
                                    DT::dataTableOutput("DTtable")
                                )
                            ) 
                   )
        )
    )
)


