library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(ggfortify)
library(DT)
library(shinycssloaders)

#read in dataset
games <- read_csv("gameSales.csv")

#convert Year to numeric
games$Year_of_Release <- as.numeric(games$Year_of_Release)

#convert user score to same scale as critic score
games$User_Score <- as.numeric(games$User_Score) * 10

#keep only complete cases
games <- games[complete.cases(games), ]

#any publishers with less than 200 games should be modeled as 'other'
pubCount <- as.data.frame(table(games$Publisher),stringsAsFactors = FALSE) %>% 
    dplyr::filter(Freq >= 200) %>% select(Var1)
games$Publisher <- if_else(games$Publisher %in% pubCount$Var1,games$Publisher,"Other")

#exclude columns we don't need
games <- games[,!(names(games) %in% c("NA_Sales","EU_Sales","JP_Sales","Other_Sales","Developer"))]