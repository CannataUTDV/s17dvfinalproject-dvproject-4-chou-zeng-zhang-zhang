#ui.R
require(shiny)
require(shinydashboard)
require(DT)
require(leaflet)
require(plotly)

dashboardPage(skin= "purple",
  dashboardHeader(title=tags$b("Project 7")),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Barchart Visualizations (1-3)", tabName = "viz1", icon = icon("dashboard"))
      )
    ),
  
  dashboardBody(
    tabItems(
      # Begin Barchart 1 tab content.
      tabItem(tabName = "viz1",
              tabsetPanel(
                tabPanel("Data",  
                         tags$h3(tags$b("Barchart Data")),
                         hr(),
                         actionButton(inputId = "click4",  label = "To get data, click here"),
                         hr(), # Add space after button.
                         tags$h4(tags$b('Here is data for the "Average Growth for 5 Highest Revenue State" tab')),
                         hr(),
                         DT::dataTableOutput("barchartData1"),
                         hr(),
                         tags$h4(tags$b('Here is data for the "High Revenue ID Sets on Growth" tab')),
                         hr(),
                         DT::dataTableOutput("barchartData2"),
                         hr(),
                         tags$h4(tags$b('Here is data for the "Average Revenue for 5 Highest Revenue State" tab')),
                         hr(),
                         DT::dataTableOutput("barchartData3")
                ),
                tabPanel("Vis.1: Average Growth for 5 Highest Revenue State", "Black = Average Growth Rate, Red = Average Growth Rates of Five States, and  Blue = Average Growth Rate - Average Growth Rate of Five States", plotOutput("barchartPlot1", height=1500),
                          tags$h4(tags$b('Insights of the Graph')),
                          tags$h5("This barchart displays the average growth rate in selected states for selected industry. The states selected are the top 5 states which has the highest sum revenue during 2015. The industry set used as filter includes the 6 industries which has the highest sum revenue in 2015. The horizontal bars represent the average growth rates for the specific industry in individual states. The window reference line is the average of the average growth rate for the industry in selectedstates."),
                         tags$h5("From the barchart we see that in Business product and services industry, state Georgia is growing fast, because its average growth rate is extremely higher than other states??. In Construction industry, California is playing the leading role. And in Human Resources industry, Florida shows the fastest growth. However, for Health industry, there is no obvious leading state; all states developed it well during year2015.")
                         ),
                tabPanel("Vis.2: High Revenue ID Sets on Growth", plotlyOutput("barchartPlot2", height=500),
                         tags$h4(tags$b('Insights of the Graph')),
                         tags$h5("We create a ID Set using company id and its revenue. We select companies whose revenue greater than 10 billion as high revenue companies, and there are 19 of them. The bar chart displays the growth rate for these 19 companies."),
                         tags$h5("Among these 19 companies with highest revenue, only two companies' growth rate exceeds the average growth rate across the total 5000 companies.")
                         ),
                tabPanel("Vis.3: Average Revenue for 5 Highest Revenue State", "Black = Average Revenue, Red = Average Revenue of all Companies within a State, and  Blue = Average Revenue - Average Revenue of all Companies within a State", plotOutput("barchartPlot3", height=1500),
                         tags$h4(tags$b('Insights of the Graph')),
                         tags$h5("We first create a set of the five states with the highest revenue. For all the companies in these five states, we group them by years on the list. The bar chart shows the average revenue each group. We also calculate the difference between each bar and the average for the pane."),
                         tags$h5("In Texas, the longer companies stay on the list, the companies tend to have higher revenue. However, the extremes appear at the 9th year in Georgia and at 7th years in New York.")
                         )
              )
      )
      # End Barchart 1 tab content.
      
    )
  )
)



