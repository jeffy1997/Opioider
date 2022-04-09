#Opioid App Jeffy 0693126

# UI Layer to design layout

#Import shiny
library(shiny)

# Page 1 - Overview Page

intro_panel <- tabPanel(
  "Overview",
  
  titlePanel("Opioid Overdose"),
  
  img(src = "opimg.jpg",align="right",height="70%", width="40%"),
  
  p("Opioids are a class of drugs that interact with the body to relieve/suppress acute (at times chronic) pain and can create feelings of euphoria
.Opioids and drug abuse have become global issues in the last decade. The (CDC) estimates that the economic impact of legally obtained opioid use in the United States is $78.5 billion a year, which also covers the costs of healthcare and criminal justice involvement. There were three waves of opioids in the years from 1990 with natural prescription opioids or methadone. The second wave was in 2010 with the rapid increase in heroin abuse and related deaths. The most recent wave occurred in 2013 with illicitly manufactured fentanyl abuse, cocaine, and counterfeit pills. The addiction center highlights that there have been 100,000+ American deaths due to overdose between the period of April 2020 and April 2021. Drug overdose deaths often require lengthy analysis, investigations and death certificates based on the cause of death. Data analytics is the key in overcoming this problem. By using data analytics, government agencies can understand where to allocate their resources judiciously to fight the opioid crisis in an efficient manner."),
  p(a(href = "https://www.cdc.gov/drugoverdose/epidemic/index.html", "Click here for more info on Opioids by Center of Disease Control"))
)

# Page 2 Second Panel to describe Gender wise breakdown
second_panel <- tabPanel(
  "Gender Wise Breakdown",
  titlePanel("Deaths by Gender"),
  plotOutput("histplot")
)


#Page 3 to describe Age wise breakdown of deaths
sidebar_content <- sidebarPanel(
  selectInput(
    "sex",
    label = "Select Sex",
    choices = c("Male","Female")
  )
)
main_content <- mainPanel(
  plotOutput("dplot")
)

third_panel <- tabPanel(
  "Age Group Breakdown",
  titlePanel("Death by Age & Gender"),
  p("Change Gender to see dynamic visualization"),
  sidebarLayout(
    sidebar_content, main_content
  )
)

#Page 4 to describe most consumed drugs by ethnicity
sidebar_content <- sidebarPanel(
  selectInput(
    "race",
    label = "Ethnicity",
    choices = c("Black",
                "White",
                "Asian, Other",
                "Hispanic, White",
                "Asian Indian",
                "Hispanic, Black",
                "Chinese",
                "Native American, Other",
                "Hawaiian",
                "Other",
                "Unknown"
   )
 )
)
main_content <- mainPanel(
  plotOutput("wcplot")
)

fourth_panel <- tabPanel(
  "Most consumed Drugs",
  titlePanel("Top drugs leading to deaths for different ethnicities"),
  p("Select Ethnicity to view most consumed drugs by ethnicity"),
  sidebarLayout(
    sidebar_content, main_content
  )
)

# Page 5 to plot cause of death breakdown
fifth_panel <- tabPanel(
  "Cause Of Death Breakdown",
  titlePanel("Cause of Death for different opioids"),
  plotOutput("codplot")
)


## Page 6 to display table and map panel
sidebar_content <- sidebarPanel(
  radioButtons("odType", "Choose type of Opioid Overdose:",
               c("All Opioids" = "All Opioids", 
                 "Heroin" = "Heroin",
                 "Other Opioids (includes Prescription)" = "Other opioids",
                 "Other Synthetic Narcotics (includes fentanyl)" = "Other synthetic narcotics",
                 "Methadone" = "Methadone" )),
  radioButtons("statType", "Choose Statistic:",
               c("Total Deaths" = "Deaths", 
                 "Death Rate (per 100,000)" = "Death_Rate",
                 "As Percentage of All Deaths" = "Pct_of_Total_Deaths")),
  h3(tableOutput("tableYear")),
  htmlOutput('myTable')
)

main_content <- mainPanel(
  h2("Change filters to view dynamic map visualization. You can also click the play option below the slider."),
  sliderInput("Year", "Select Year to be displayed:",
              min = 2000, max =2015, value = 2000, step = 1,
              animate = TRUE, sep = "", width = 500 ),
  h3(textOutput("mapYear")),
  htmlOutput("choropleth")
)

map_panel <- tabPanel(
  "Spatial Statistics",
  sidebarLayout(
    sidebar_content, main_content
  )
)


## Arranging Panels together
ui <- navbarPage(
  "Opioid Crisis",
  intro_panel,
  second_panel,
  third_panel,
  fourth_panel,
  fifth_panel,
  map_panel
)
