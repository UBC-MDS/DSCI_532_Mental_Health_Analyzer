library(shiny)
library(tidyverse)
library(ggplot2)
library(plotly)
# install.packages("shinythemes")
library(shinythemes)

data <- read.csv("data/cleaned_survey_data.csv", header=TRUE, stringsAsFactors = FALSE)


ui <- fluidPage(#tags$style(type = "text/css", ".irs-grid-text {font-family: 'arial'; color: white; bottom: 17px; z-index: 1;}"),
                theme = shinytheme("flatly"),
                titlePanel(h2("Mental Health in Tech Analyzer"),
                           windowTitle = "Mental Health in Tech Analyzer"),
                sidebarLayout(
                  sidebarPanel(
                    h4(selectInput("questionInput", h3("Question"), 
                                   choices = c("1. Do you think that discussing a mental health issue with your employer would have negative consequences?"="mental_health_consequence",
                                               "2. Would you be willing to discuss a mental health issue with your coworkers?"="coworkers",
                                               "3. Would you be willing to discuss a mental health issue with your direct supervisor(s)?"="supervisor",
                                               "4. Would you bring up a mental health issue with a potential employer in an interview?"="mental_health_interview",
                                               "5. Do you know the options for mental health care your employer provides?"="care_options",
                                               "6. Has your employer ever discussed mental health as part of an employee wellness program?"="wellness_program"), 
                                   selected = "mental_health_consequence")),
                    h4(selectInput("countryInput", h3("Country"), 
                                   choices = c("All", "United States", "United Kingdom",
                                               "Canada", "Germany", "Ireland",
                                               "Netherlands", "Australia", "France",
                                               "Others"),
                                   selected = "All")),
                    h4(radioButtons("genderInput", h3("Gender"),
                                    choices = c("All", "Male", "Female"), 
                                    selected = "All")), 
                    sliderInput("ageInput", h3("Age"), 18, 62, c(18, 62))
                  ),
                  mainPanel(
                    plotlyOutput("barPlot"), plotlyOutput("ageHist")
                  )
                ))


server <- function(input, output) {
  
  dataFilter <- reactive({
    
    # select what is going to be analyzed based on 'questionInput' 
    filteredData <- data %>%
      select(Country, Gender, Age, input$questionInput)
    
    # filter data based on 'countryInput', which represents selected country 
    if(input$countryInput == 'All') {
      filteredData <- filteredData
    } else {
      if (input$countryInput == "Others"){
        filteredData <- filteredData %>%
          filter(!(Country %in% c("United States", "United Kingdom",
                                  "Canada", "Germany", "Ireland",
                                  "Netherlands", "Australia", "France")))
      } else {
        filteredData <- filteredData %>%
          filter(Country == input$countryInput)
      } 
    }
    
    # filter data based on 'genderInput', which represents selected gender
    if(input$genderInput == 'All') {
      filteredData <- filteredData
    } else {
      filteredData <- filteredData %>%
        filter(Gender == input$genderInput)
    }
    
    # filter data based on 'ageInput', which represents selected age range
    filteredData <- filteredData %>%
      filter(Age >= input$ageInput[1] & Age <= input$ageInput[2])
  })
  
  # plot the bar chart based on filtered data
  output$barPlot <- renderPlotly({
    
    # initiate plot title text 
    if(input$questionInput == 'mental_health_consequence') {
      myTitle <- 'Do you think that discussing a mental health issue\n with your employer would have negative consequences? '
    } else if(input$questionInput == 'coworkers') {
      myTitle <- 'Would you be willing to discuss a mental \n health issue with your coworkers?'
    } else if(input$questionInput == 'supervisor') {
      myTitle <- 'Would you be willing to discuss a mental \n health issue with your direct supervisor(s)?'
    } else if(input$questionInput == 'mental_health_interview') {
      myTitle <- 'Would you bring up a mental health issue \n with a potential employer in an interview?'
    } else if(input$questionInput == 'care_options') {
      myTitle <- 'Do you know the options for mental health \n care your employer provides?'
    } else if(input$questionInput == 'wellness_program') {
      myTitle <- 'Has your employer ever discussed mental \n health as part of an employee wellness program?'
    }
    
    barChart <- dataFilter() %>% 
      ggplot(aes(x = !!sym(input$questionInput), fill = !!sym(input$questionInput))) + 
      geom_bar(colour="black", width = 0.5) +
      scale_y_continuous(expand = c(0, 0)) +
      theme(panel.grid.minor = element_blank(),
            panel.background = element_blank(), # remove plot background
            plot.title = element_text(size = 18, hjust = 10, vjust = 10, lineheight = 1.2),
            plot.margin = margin(100, 50, 2, 2),
            axis.text.x = element_text(size = 15, face = "bold", color = "black"),
            axis.text.y = element_text(size = 15, face = "bold", color = "black"),
            axis.title.x = element_blank(),
            axis.title.y = element_text(size = 15, color = "black"),
            legend.title = element_blank(),
            axis.line = element_line(size = 1, color = "black"),
            legend.position = "none") +
      labs(title=myTitle, y = "Count")
    ggplotly(barChart, tooltip="y") %>% layout(hoverlabel = list(font=list(size=20)))
  })
  
  # plot age distribution
  output$ageHist <- renderPlotly ({
    ageDist <- dataFilter() %>% 
      ggplot(aes(x=Age))+
      geom_histogram(bins = 30) + 
      scale_y_continuous(expand = c(0, 0)) +
      theme(panel.grid.minor = element_blank(),
            panel.background = element_blank(), # remove plot background
            plot.title = element_text(size = 18, hjust = 10, vjust = 10, lineheight = 1.2),
            plot.margin = margin(100, 50, 2, 2),
            axis.text.x = element_text(size = 15, face = "bold", color = "black"),
            axis.text.y = element_text(size = 15, face = "bold", color = "black"),
            axis.title.x = element_text(size = 15, color = "black"),
            axis.title.y = element_text(size = 15, color = "black"),
            legend.title = element_blank(),
            axis.line = element_line(size = 1, color = "black"),
            legend.position = "none") +
      labs(x = "Age", y = "Count", title = "Age distribution of respondents")
    ggplotly(ageDist, tooltip = "skip") %>% layout(hoverlabel = list(font=list(size=20)))
  })
}

shinyApp(ui = ui, server = server)

