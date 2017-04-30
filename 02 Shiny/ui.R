#ui.R
require(shiny)
require(shinydashboard)
require(DT)
require(leaflet)
require(plotly)

dashboardPage(skin= "purple",
  dashboardHeader(title=tags$b("Project ")),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Box Plots", tabName = "boxplot", icon = icon("dashboard")),
      menuItem("Histograms", tabName = "histogram", icon = icon("dashboard")),
      menuItem("Scatter Plots", tabName = "scatter", icon = icon("dashboard")),
      menuItem("Crosstabs, KPIs, Parameters", tabName = "crosstab", icon = icon("dashboard")),
      menuItem("Barchart Table Calculations", tabName = "barchart", icon = icon("dashboard")),
      menuItem("Choropleth Map", tabName = "choropleth", icon = icon("dashboard"))
      )
    ),
  
  dashboardBody(
    tabItems(
      #------------------------------------------Begin Box Plots tab content-------------------------------------------------
       tabItem(tabName = "boxplot",
               tabsetPanel(
                 tabPanel("Data",  
                          #uiOutput("boxplotRegions"), # See http://shiny.rstudio.com/gallery/dynamic-ui.html,
                          tags$h3(tags$b("Add a Title")),
                          tags$h5("Provide instructions on what to do with the button:"),
                          actionButton(inputId = "click1",  label = "To get data, click here"),
                          hr(), 
                          DT::dataTableOutput("boxplotData1")
                 ),
                 tabPanel("Simple Box Plot", 
                          sliderInput("boxSalesRange1", "Number of Households:", # See https://shiny.rstudio.com/articles/sliders.html
                          min = 0, 100,#min(df1$number_households_participated), max = max(df1$number_households_participated), 
                          value = 0, 100),#c(min(df1$number_households_participated), max(df1$number_households_participated)))
                          # sliderInput("range5a", "Loop through Quarters:", 
                          # min(globals$Order_Date), 
                          # max(globals$Order_Date) + .75, 
                          # max(globals$Order_Date), 
                          # step = 0.25,
                          # animate=animationOptions(interval=2000, loop=T)),
                          plotlyOutput("boxplotPlot1", height=500))
               )),
      
      #------------------------------------------Begin Histogram tab content------------------------------------------------
      tabItem(tabName = "histogram",
              tabsetPanel(
                tabPanel("Data",  
                         tags$h3(tags$b("Score Distribution for Coastal and Landlocked States")),
                         tags$h5("Please click the button below to see the detailed score records for each state"),
                         actionButton(inputId = "click2",  label = "To get data, click here"),
                         hr(), # Add space after button.
                         DT::dataTableOutput("histogramData1")
                ),
                tabPanel("Simple Histogram", plotOutput("histogramPlot1", height=700))
              )
      ),
      #------------------------------------------Begin Scatter Plot tab content----------------------------------------------
      tabItem(tabName = "scatter",
              tabsetPanel(
                tabPanel("Data",  
                         #uiOutput("scatterStates"), # See http://shiny.rstudio.com/gallery/dynamic-ui.html,
                         tags$h3(tags$b("Test Attempt Ratio vs. Equality for Blacks and Hispanics")),
                         tags$h5("Click the button below to get Ginis index and test attempy ratio for Blacks and Hispanics"),
                         actionButton(inputId = "click3",  label = "To get data, click here"),
                         hr(), # Add space after button.
                         DT::dataTableOutput("scatterData1")
                ),
                tabPanel("Simple Scatter Plot", plotOutput("scatterPlot1", height=700))
              )
      ),
      #------------------------------------------Begin Crosstabs KPI Parameters --------------------------------------------
      tabItem(tabName = "crosstab",
              tabsetPanel(
                tabPanel("Data",
                         tags$h3(tags$b("KPI: Growth (Percent)")),
                         tags$h5("Adjust the intervals for the KPI levels using the sliders:"),
                         sliderInput("KPI1", "Low:", min = 0, max = 10,  value = 10),
                         sliderInput("KPI2", "Medium:", min = 11, max = 50,  value = 50),
                         sliderInput("KPI3", "High:", min = 51, max = 200, value = 200),
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
                         #uiOutput("regions2"), # See http://shiny.rstudio.com/gallery/dynamic-ui.html
                         tags$h3(tags$b("Add a Title")),
                         tags$h5("Provide instructions on what to do with the button:"),
                         actionButton(inputId = "click5",  label = "To get data, click here"),
                         hr(),
                         'Here is data for the "Barchart with Table Calculation" tab',
                         hr(),
                         DT::dataTableOutput("barchartData1"),
                         hr(),
                         'Here is data for the "High Discount Orders" tab',
                         hr(),
                         DT::dataTableOutput("barchartData2"),
                         hr(),
                         'Here is data for the "High Sales Customers" tab',
                         hr(),
                         DT::dataTableOutput("barchartData3")),
                tabPanel("Barchart with Table Calculation", "*Add description for each colored line", plotOutput("barchartPlot1", height=1500)),
                tabPanel("High Sales Customers", plotlyOutput("barchartPlot2", height=700) )
              )),
      # End Barchart tab content.
      #------------------------------------------Begin Choropleth tab content-----------------------------------------------
      # Begin Choropleth tab content.
      tabItem(tabName = "choropleth",
              tabsetPanel(
                tabPanel("Data",  
                         tags$h3(tags$b("Income Inequality in the U.S.")),
                         tags$h5("Click the button below to get the Gini index for each state in the U.S."),
                         actionButton(inputId = "click6",  label = "To get data, click here"),
                         hr(),
                         DT::dataTableOutput("choroData1")),
                tabPanel("The Map Diagram", plotOutput("choroMap1"), height=900 )
              )
      )
      # End Choropleth tab content.
      
    )
  )
)



