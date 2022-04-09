#Opioid App Jeffy 0693126

#Server file to write logic for analysis and visuals


#Import Libraries

library(rlang)
library(shiny)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(lubridate)
library(ggthemes)
library(janitor)
library(wordcloud)
library(tidytext)
library(googleVis)
library(plotly)

#Reading drug deaths data and removing unnecessary columns like log information

OD <- read.csv("drug_deaths.csv")
OD <- OD %>% clean_names()
OD_dm <- OD %>% mutate_all(list(str_to_title)) %>% mutate(date = mdy_hms(date))

# Dataset for spatial analysis
overdose_states <- read.csv("overdose_processed_states.csv", header = T)
overdose_states <- overdose_states[,1:6]

# Shiny server function which can receive dynamic inputs and plot respective outputs as mentioned in UI

shinyServer <- function(input, output) {

#Plot for Deaths by gender    
  output$histplot <- renderPlot({
  
  OD_dm%>% select(sex) %>% 
      filter(!is.na(sex)& sex != "",
             sex != "Unknown") %>% 
      count(sex, sort = TRUE) %>% 
      mutate(percent = paste0(round(n/sum(n) * 100,0),"%")) %>% 
      ggplot(aes(x = sex, y = n, label = percent, fill = sex)) +
      geom_bar(stat = "identity") +
      geom_text(col = "black" , vjust = 1.5, fontface = "bold", size = 5) +
      scale_fill_tableau(palette = "Nuriel Stone") +
      theme(legend.position = "none") +
      labs(
        x = "Sex",
        y = "Count"
      )
  })

#Plot for deaths by age group with gender as input parameter    
  output$dplot <- renderPlot({
    OD_sex<-OD%>%filter(sex == input$sex)
    ODAgeGrp <- OD_sex %>% select(id, age) %>% 
      filter(!is.na(age)) %>% mutate(age = as.numeric(age)) %>% 
      mutate(AgeGrp = as.factor(cut(age, breaks = c(14,20,30,49,65,Inf),
                                    labels = c("14-20", "21-29", "30-49", "50-65", "Over 65"))))
    mytable <- table(ODAgeGrp$AgeGrp)
    agelabels = c("14-20", "21-29", "30-49", "50-65", "Over 65")
    pie_labels <- paste0(agelabels,"=",round(100 * mytable/sum(mytable), 1), "%")
    pie(mytable, labels = pie_labels,main="Drug Abuse Deaths by AgeGroup")
  })

  
#Plot for wordcloud of most consumed drugs with race as input parameter
  output$wcplot <- renderPlot({
    od_mod_wc<-OD%>%filter(race == input$race)
    
    cod_words <- od_mod_wc %>% select(id,cod) %>% 
    unnest_tokens(word, cod) %>%
    anti_join(stop_words)
    
    count_word <- cod_words %>%
    count(word, sort = TRUE)
    
    
    wordcloud(words = count_word$word,  
              freq = count_word$n, 
              min.freq = 5,  
              max.words = nrow(count_word), 
              random.order = FALSE,  
              rot.per = 0.1,  
              colors = brewer.pal(8, "Dark2")) 
  })
  
#Plot for cause of death description
  output$codplot <- renderPlot({OD %>% mutate(cod = fct_lump(cod, n = 10)) %>%
      filter(!is.na(cod),
             cod != "Other",
             !is.na(sex)) %>% 
      group_by(cod, sex) %>% 
      summarise(total = n()) %>%
      arrange(desc(total)) %>% 
      ggplot(aes(x = fct_reorder(cod,total), y = total, fill = sex, label = total)) +
      geom_col(position = "dodge")+
      geom_point()+
      geom_text(hjust = -0.5, vjust = 0)+
      coord_flip()+
      scale_y_continuous(expand = expansion(add = c(0,20)))+
      scale_fill_tableau(palette = "Tableau 20") +
      labs(
        title = "Most common cause of death ",
        x = "cause of death",
        y = "death count"
      )
  }) 

  
#Plot for spatial analysis and statistics  
  displayYear <- reactive({
    input$Year
  })
  stat_type <- reactive({
    input$statType
  })
  # Reactive label for the choropleth
  output$mapYear <- renderText({
    stat <- stat_type()
    
    if(stat == "Pct_of_Total_Deaths"){
      paste("Opioid Overdoses as % of all Deaths in", displayYear())
    } else if (stat == "Death_Rate"){
      paste("Opioid Overdose Death Rate in", displayYear())
    } else if (stat == "Deaths") {
      paste("Total Opioid Overdose Deaths in", displayYear())
    }
  })
  
  
  # reactive function that subsets the data based on slider and radio buttons
  df_subset <- reactive({
    data <- overdose_states[(overdose_states$Year == displayYear() & overdose_states$Multiple_Cause_of_death == input$odType),]
    
    return(data)
  })
  
  
  
  # Reactive Choropleth map that changes based on radio button/slider selections
  output$choropleth <- renderGvis({
    data <- df_subset()
    stat <- stat_type()
    
    gvisGeoChart(data, "State", stat, options = list(region="US",
                                                     displayMode = "regions",
                                                     resolution = "provinces",
                                                     colors = "['#3B727C', '#22B4A7', '#9DE7BE', '#84C29F',
                                                                  '#1B9CC6', '#1A97BF', '#198FB5', '#016699', '#016699']",
                                                     width = 500, 
                                                     height = 300))
  })
  
  
  
}