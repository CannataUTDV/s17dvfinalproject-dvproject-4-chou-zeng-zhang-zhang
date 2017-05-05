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
                                "We noticed that the distributions are almost identical, suggesting that the geography of test takers has little to do with the AP score outcomes. Also, both distributions are bimodal and almost symmetric, providing insight on the polarity of scores for the AP CS test."
                                ),
                         tags$br(),
                         tags$p("Lastly, we can see that there were far more AP scores for coastal states than there were for landlocked states. Although the bulk of this is most likely attributed to greater population size and density in coastal states, it may be worth looking into resources that coastal states have to facilitate more test takers.")
                         )
                )
              ),

      # Scatter plot
      tabItem(tabName = "scatter",
              tabsetPanel(
                tabPanel("Data",  
                         tags$h3(tags$b("Income Inequality and Test Takers per Capita for Blacks and Hispanics")),
                         tags$h5("Click the button below to get Gini index and test attempt ratio for Blacks and Hispanics, and Others."),
                         actionButton(inputId = "click3",  label = "Fetch data"),
                         hr(),
                         DT::dataTableOutput("scatterData1")
                ),
                tabPanel("Visualization", plotOutput("scatterPlot1", height = 600)),
                tabPanel("Details",
                         tags$h3(tags$b("About this visualization:")),
                         tags$p("We wanted to explore whether or not income inequality had an effect on the test attempt rate for Blacks and Hispanics in each state. We used the Gini index from the ACS census data in 2015 as the standard measure of income inequality for each state. We calculated a field of test takers per capita for each group within each state in order to reflect the test attempt rates for minority groups. This is calculated as follows:",
                                withMathJax(helpText("$$\\frac{\\% \\ group \\ out \\ of \\ test \\ takers \\ in \\ state} {\\% \\ group \\ out \\ of \\ state \\ population} \\cdot 100$$")),
                                tags$p("At first glance, there seemed to be an exponential relationship between the Gini index and the test attempt rate for both groups. However, after adding fit lines (using Loess regression), we see that this initial reaction is not supported by the regression. The Gini index does not seem to have any significant relationship with the test takers per capita metric. Most of the states had less than 100 test takers per capita for Blacks and Hispanics, but there are some extreme values at various Gini index values for both groups. We also see that both hispanic and black test takers had generally lower test takers per capita than the others group, regardless of the Gini index for the state.")
                                )
                         )
              )
      ),
      
      # Crosstab
      tabItem(tabName = "crosstab",
              tabsetPanel(
                tabPanel("Data",
                         tags$h3(tags$b("KPI: Pass Rate")),
                         tags$h5("Adjust the intervals for the pass rate using the sliders:"),
                         sliderInput("KPI1", "Low:", min = 0, max = 60,  value = 60),
                         sliderInput("KPI2", "Medium:", min = 60, max = 80,  value = 80),
                         actionButton(inputId = "click4",  label = "Fetch data"),
                         hr(),
                         DT::dataTableOutput("crosstabData1")
                ),
                tabPanel("Crosstab Plot", plotOutput("crosstabPlot1", height = 1000)),
                tabPanel("Details", 
                         tags$h3(tags$b("About this visualization:")),
                         tags$p("The counts for each score within each state is displayed in the crosstab visualization. Each cell contains the counts, and each row is colored by the passing rate for the respective state. States that did not have enough scores were given a pass rate value of NA to avoid the creation of misleading data.")
                         )
                )
              ),

      # Barchart
      tabItem(tabName = "barchart",
              tabsetPanel(
                tabPanel("Data",  
                         tags$h3(tags$b("Passed Rate by Gender by High Income States")),
                         tags$h5("Click the button below to see the percentage of minorities taking the test for each state."),
                         actionButton(inputId = "click5",  label = "Fetch data"),
                         hr(),
                         DT::dataTableOutput("barchartData1")
                         ),
                tabPanel("Barchart with Table Calculation", plotOutput("barchartPlot1", height = 1200)),
                tabPanel("Details",
                         tags$h3(tags$b("About this visualization:")),
                         tags$p("This barchart displays the percentage of total test takers from each minority group in each state, for states with a median household income greater than $60,000. We noticed that Maryland had the largest proportion of hispanic test takers. We also see that Washington and California had relatively higher proportions of females taking the test, with percentages of 25.32% and 21.64% respectively. Lastly, Alaska and Utah had no blacks or hispanics that took the test, but this is most likely due to the fact that they have relatively low percentages of black and hispanic residents to begin with (see", 
                                tags$span(tags$a(href="https://www.census.gov/quickfacts/table/PST045216/02",
                                                 target="_blank", 
                                                 "Alaska's demographics"
                                                 )
                                          ),
                                "and",
                                tags$span(tags$a(href="https://www.census.gov/quickfacts/table/PST045216/49", target="_blank", "Utah's demographics"
                                                 )
                                          ),
                                ")."
                                )
                         )
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
                tabPanel("Details",
                         tags$h3(tags$b("About this visualization:")),
                         tags$p("Using the census data, we created a choropleth map displaying the Gini index in the US. This map was created using Ari Lamstein's Choroplethr and Ezra Haber Glenn's ACS packages. The classes are created using the", 
                                tags$span(tags$a(href="https://en.wikipedia.org/wiki/Jenks_natural_breaks_optimization", 
                                                 target="_blank", 
                                                 "Jenks natural breaks classification method"
                                                 )
                                          ),
                                "."
                                ),
                         tags$br(),
                         tags$p("The Gini index is a normalized measure of income inequality. We observed that many coastal states have generally higher index values than landlocked states, which compelled us to examine the AP CS score distributions between coastal and landlocked states, as seen in the histogram tab."
                                )
                         )
              )
      )
      
    )
  )
)



