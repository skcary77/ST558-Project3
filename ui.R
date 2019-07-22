library(tidyverse)
library(shiny)
library(plotly)

#allow users to create table by categorical variables
catVars <- c("Platform","Year_of_Release","Genre","Publisher","Developer","Rating")
#allow users to change scatter plot x-variable
scatterX <- c("Critic_Score","User_Score")

#https://datascience-enthusiast.com/R/shiny_ML.html

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
                                                    #textOutput("info"),
                                                    tableOutput("table")
                                            )
                                    )
                                    
                           ),
                           
                           tabPanel("Clustering",
                                    HTML("Blank")
                           ),
                           
                           navbarMenu("Modeling",
                                      tabPanel("Linear Regression",
                                               sidebarLayout(
                                                       sidebarPanel(
                                                               selectInput("lmPredictors", "Select variables to include", choices = c("Critic_Score","User_Score"),multiple=TRUE),
                                                               br()
                                                       ),
                                                       
                                                       # Show output
                                                       mainPanel(
                                                               #plotOutput("lmFit"),
                                                               verbatimTextOutput("lmSummary")
                                                       )
                                               ) 
                                      ),
                                      
                                      tabPanel("Unsupervised Learning",
                                               fluidRow(
                                                       HTML("Blank")
                                               ) 
                                      )
                                      
                           )
                )
        )
)


