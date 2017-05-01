#ui.R
require(shiny)
require(shinydashboard)
require(DT)
require(leaflet)
require(plotly)

dashboardPage(skin= "purple",
  dashboardHeader(title=tags$b("Final Project")),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Box Plot", tabName = "boxplot", icon = icon("dashboard")),
      menuItem("Histogram", tabName = "histogram", icon = icon("dashboard")),
      menuItem("Scatter Plot", tabName = "scatter", icon = icon("dashboard")),
      menuItem("Crosstab", tabName = "crosstab", icon = icon("dashboard")),
      menuItem("Barchart", tabName = "barchart", icon = icon("dashboard")),
      menuItem("Choropleth Map", tabName = "choropleth", icon = icon("dashboard"))
      )
    ),
  
  dashboardBody(
    tabItems(
      #------------------------------------------Begin Box Plots tab content-------------------------------------------------
       tabItem(tabName = "boxplot",
               tabsetPanel(
                 tabPanel("Data",  
                          tags$h3(tags$b("Test Takers per Teacher by Region")),
                          tags$h5("Click the button below to see the yield per teacher for different regions."),
                          actionButton(inputId = "click1",  label = "Fetch Data"),
                          hr(), 
                          DT::dataTableOutput("boxplotData1")
                          ),
                 tabPanel("Visualization", plotOutput("boxplotPlot1", height=700)),
                 tabPanel("Details")
                 )
               ),
      
      #------------------------------------------Begin Histogram tab content------------------------------------------------
      tabItem(tabName = "histogram",
              tabsetPanel(
                tabPanel("Data",  
                         tags$h3(tags$b("Score Distributions for Coastal and Landlocked States")),
                         tags$h5("Click the button below to see score records for each state."),
                         actionButton(inputId = "click2",  label = "Fetch data"),
                         hr(), # Add space after button.
                         DT::dataTableOutput("histogramData1")
                ),
                tabPanel("Visualization", plotOutput("histogramPlot1", height=700)),
                tabPanel("Details")
              )
      ),
      #------------------------------------------Begin Scatter Plot tab content----------------------------------------------
      tabItem(tabName = "scatter",
              tabsetPanel(
                tabPanel("Data",  
                         tags$h3(tags$b("Income Inequality and Test Attempt Ratio for Black and Hispanic Test Takers")),
                         tags$h5("Click the button below to get Gini index and test attempt ratio for Blacks and Hispanics."),
                         actionButton(inputId = "click3",  label = "Fetch data"),
                         hr(),
                         DT::dataTableOutput("scatterData1")
                ),
                tabPanel("Visualization", plotOutput("scatterPlot1", height=700)),
                tabPanel("Details")
              )
      ),
      #------------------------------------------Begin Crosstabs KPI Parameters --------------------------------------------
      tabItem(tabName = "crosstab",
              tabsetPanel(
                tabPanel("Data",
                         tags$h3(tags$b("KPI: Passed Rate")),
                         tags$h5("Adjust the intervals for the per capita income using the sliders:"),
                         sliderInput("KPI1", "Low:", min = 0, max = 60,  value = 60),
                         sliderInput("KPI2", "Medium:", min = 60, max = 75,  value = 75),
                         actionButton(inputId = "click4",  label = "Fetch Data"),
                         hr(),
                         DT::dataTableOutput("crosstabData1")
                ),
                tabPanel("Crosstab Plot", plotOutput("crosstabPlot1", height=1000)),
                tabPanel("Details", 
                         tags$h3(tags$b("About this visualization:")),
                         tags$p("This visualization examines the relationship between the number of years that companies were on the", tags$span(tags$a(href="https://www.inc.com/inc5000/list/2016/", target="_blank", "Inc. 5000 list of fastest growing companies in America")), "and the percent growth they experienced in the past 3 years. The numbers in each cell represent the percent growth for the companies in 2016. The KPI is the level of growth, defined as low (0-10%), medium (11%-50%), and high (51%+)."
                         ),
                         tags$br(),
                         tags$p("We looked at how these metrics varied from state to state, and we can see that, in general, younger companies have had much larger growth than those who have been on the list in recent years. This is most likely due to these companies being smaller and having less net worth, thus amplifying the magnitude of any increase in growth.")
                         ))),
      #------------------------------------------Begin Barchart 1 tab content-----------------------------------------------
      # Begin Barchart tab content.
      tabItem(tabName = "barchart",
              tabsetPanel(
                tabPanel("Data",  
                         tags$h3(tags$b("Different Taking Rates by High Income States")),
                         tags$h5("Click the button below to see the percentage of minorities taking the test for each state."),
                         actionButton(inputId = "click5",  label = "Fetch data"),
                         hr(),
                         DT::dataTableOutput("barchartData1")
                         ),
                tabPanel("Barchart with Table Calculation", plotOutput("barchartPlot1", height=1500)
                         ),
                #tabPanel("High Sales Customers", plotlyOutput("barchartPlot2", height=700)),
                tabPanel("Details")
              )),
      # End Barchart tab content.
      #------------------------------------------Begin Choropleth tab content-----------------------------------------------
      # Begin Choropleth tab content.
      tabItem(tabName = "choropleth",
              tabsetPanel(
                tabPanel("Data",  
                         tags$h3(tags$b("Income Inequality in the U.S.")),
                         tags$h5("Click the button below to get income-related census data for each state."),
                         actionButton(inputId = "click6",  label = "Fetch data"),
                         hr(),
                         DT::dataTableOutput("choroData1")),
                tabPanel("Visualization", plotOutput("choroMap1"), height=900),
                tabPanel("Details")
              )
      )
      # End Choropleth tab content.
      
    )
  )
)



