#ui.R
require(shiny)
require(shinydashboard)
require(DT)

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
      
      # Box plot
      tabItem(tabName = "boxplot",
              tabsetPanel(
                tabPanel("Data",
                         tags$h3(tags$b("Test Takers per Teacher by Region")),
                         tags$h5("Click the button below to see the yield per teacher for different regions."),
                         actionButton(inputId = "click1",  label = "Fetch data"),
                         hr(), 
                         DT::dataTableOutput("boxplotData1")
                         ),
                tabPanel("Visualization", plotOutput("boxplotPlot1", height = 600)),
                tabPanel("Details",
                         tags$h3(tags$b("About this visualization:")),
                         tags$p("These boxplots compare the distributions of test takers per teacher between each region. The distributions are not drastically different overall. Their spreads are rather similar, and it seems that the median ratio hovers around 10 test takers per teacher."
                                ),
                         tags$br(),
                         tags$p("It seems as though the Northeast has a lower test taker to teacher ratio than the other regions. The South certainly has the most variation in its distribution, as well as possessing the highest median test taker to teacher ratio. All but one distribution contain no outliers. The West region contains two, with each being at opposite extremes of the test taker per teacher metric."
                                )
                         )
                )
              ),
      # Histogram
      tabItem(tabName = "histogram",
              tabsetPanel(
                tabPanel("Data",  
                         tags$h3(tags$b("Score Distributions for Coastal and Landlocked States")),
                         tags$h5("Click the button below to see score records for each state."),
                         actionButton(inputId = "click2",  label = "Fetch data"),
                         hr(), # Add space after button.
                         DT::dataTableOutput("histogramData1")
                ),
                tabPanel("Visualization", plotOutput("histogramPlot1", height = 600)),
                tabPanel("Details",
                         tags$h3(tags$b("About this visualization:")),
                         tags$p("We wanted to see if there was a significant difference in the distributions in the AP score counts between US states that are", 
                                tags$span(tags$a(href="https://en.wikipedia.org/wiki/Coastal_states", target = "_blank", "geographically coastal")), 
                                "and those that are", 
                                tags$span(tags$a(href="https://en.wikipedia.org/wiki/List_of_landlocked_U.S._states", target = "_blank", "geographically landlocked.")),
                                "We noticed that the distributions are almost identical, suggesting that the geography of test takers has little to do with the AP score outcomes. Also, both distributions are bimodal and almost symmetric."
                                )
                         )
                )
              ),

      # Scatter plot
      tabItem(tabName = "scatter",
              tabsetPanel(
                tabPanel("Data",  
                         tags$h3(tags$b("Income Inequality and Test Attempt Rate for Black and Hispanic Test Takers")),
                         tags$h5("Click the button below to get Gini index and test attempt ratio for Blacks and Hispanics."),
                         actionButton(inputId = "click3",  label = "Fetch data"),
                         hr(),
                         DT::dataTableOutput("scatterData1")
                ),
                tabPanel("Visualization", plotOutput("scatterPlot1", height = 600)),
                tabPanel("Details",
                         tags$h3(tags$b("About this visualization:")),
                         tags$p("We wanted to explore whether or not income inequality had an effect on the test attempt rate for Blacks and Hispanics in each state. We used the Gini index from the ACS census data in 2015 as the standard measure of income inequality for each state. The test attempt rate is the calculated as follows:",
                                withMathJax(helpText("$$\\frac{\\% \\ minority \\ group \\ out \\ of \\ test \\ takers \\ in \\ state} {\\% \\ minority \\ group \\ out \\ of \\ state \\ population} \\cdot 100$$")),
                                tags$p("At first glance, there seemed to be an exponential relationship between the Gini index and the test attempt rate for both groups. However, after adding fit lines (using Loess regression), we see that this initial reaction is not supported by the regression. The Gini index does not seem to have any significant effect on the attempt rates. Most of the attempt rates were less than 100, but there are some extreme values at various Gini index values for both minority groups.")
                                )
                         )
              )
      ),
      
      # Crosstab
      tabItem(tabName = "crosstab",
              tabsetPanel(
                tabPanel("Data",
                         tags$h3(tags$b("KPI: Passed Rate")),
                         tags$h5("Adjust the intervals for the per capita income using the sliders:"),
                         sliderInput("KPI1", "Low:", min = 0, max = 60,  value = 60),
                         sliderInput("KPI2", "Medium:", min = 60, max = 75,  value = 75),
                         actionButton(inputId = "click4",  label = "Fetch data"),
                         hr(),
                         DT::dataTableOutput("crosstabData1")
                ),
                tabPanel("Crosstab Plot", plotOutput("crosstabPlot1", height = 1000)),
                tabPanel("Details", 
                         tags$h3(tags$b("About this visualization:")),
                         tags$p("This visualization examines the relationship between the number of years that companies were on the", tags$span(tags$a(href="https://www.inc.com/inc5000/list/2016/", target="_blank", "Inc. 5000 list of fastest growing companies in America")), "and the percent growth they experienced in the past 3 years. The numbers in each cell represent the percent growth for the companies in 2016. The KPI is the level of growth, defined as low (0-10%), medium (11%-50%), and high (51%+)."
                         ),
                         tags$br(),
                         tags$p("We looked at how these metrics varied from state to state, and we can see that, in general, younger companies have had much larger growth than those who have been on the list in recent years. This is most likely due to these companies being smaller and having less net worth, thus amplifying the magnitude of any increase in growth.")
                         ))),

      # Barchart
      tabItem(tabName = "barchart",
              tabsetPanel(
                tabPanel("Data",  
                         tags$h3(tags$b("Different Taking Rates by High Income States")),
                         tags$h5("Click the button below to see the percentage of minorities taking the test for each state."),
                         actionButton(inputId = "click5",  label = "Fetch data"),
                         hr(),
                         DT::dataTableOutput("barchartData1")
                         ),
                tabPanel("Barchart with Table Calculation", plotOutput("barchartPlot1", height = 1200)),
                tabPanel("Details")
                )
              ),

      # Choropleth
      tabItem(tabName = "choropleth",
              tabsetPanel(
                tabPanel("Data",  
                         tags$h3(tags$b("Income Inequality in the U.S.")),
                         tags$h5("Click the button below to get income-related census data for each state."),
                         actionButton(inputId = "click6",  label = "Fetch data"),
                         hr(),
                         DT::dataTableOutput("choroData1")),
                tabPanel("Visualization", plotOutput("choroMap1", height = 600)),
                tabPanel("Details")
              )
      )
      
    )
  )
)



