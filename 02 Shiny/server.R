# server.R
require(ggplot2)
require(dplyr)
require(shiny)
require(shinydashboard)
require(data.world)
require(readr)
require(DT)
require(leaflet)
require(plotly)
require(lubridate)
require(grid)
require(gridExtra)
require(RColorBrewer)
require(acs)
require(choroplethr)
require(choroplethrAdmin1)
require(choroplethrMaps)

# This is a global dataframe for the histogram plot
df_hist <- query(
    data.world(propsfile="www/.data.world"),
    dataset="achou/s-17-dv-final-project", type="sql",
    query="
    select STATE, SCORE, sum(COUNT)
    from StateScoreCounts
    group by STATE, SCORE
    ORDER by STATE, SCORE"
  ) %>% data.frame(.)
df_hist[is.na(df_hist)] <- 0
data.frame(df_hist)


shinyServer(function(input, output) { 
  # These widgets are for the Crosstabs tab.
  KPI_Low = reactive({input$KPI1})     
  KPI_Medium = reactive({input$KPI2})
  KPI_High = reactive({input$KPI3})
  
  # Create dataframe for the BoxPlot Tab
  df1 <- eventReactive(input$click1, {
    BoxPlot <- query(
      data.world(propsfile = "www/.data.world"),
      dataset="achou/s-17-dv-final-project", type="sql",
      query="select state_table.census_region_name as Region, ap_cs_2013_states_clean.yield_per_teacher as Yield
      from state_table left outer join ap_cs_2013_states_clean
      on state_table.name=ap_cs_2013_states_clean.state"
    )  %>% data.frame(.)
    })
  
  # Create dataframe for the Histogram Tab

  df2 <- eventReactive(input$click2, {df_hist
  })

  
  df_coastal <-  eventReactive(input$click2, {
  df_hist %>% dplyr::filter(STATE %in% c("Maine", "New Hampshire", "Massachussetts", "Rhode Island", "Connecticut", "New Jersey", "New York", "Delaware", "Maryland", "Virginia", "North Carolina","South Carolina", "Georgia","Florida", "Oregon", "Washington", "Alaska", "Hawaii", "California", "Florida", "Alabama", "Mississippi","Louisiana","Texas")) %>% data.frame(.)
  })
  
  df_landlock <- eventReactive(input$click2, {
  df_hist %>% dplyr::filter(STATE %in% c("Arizona", "Arkansas", "Washington DC", "Idaho", "Kentucky","Michigan","Minnesota","Montana","Nevada","New Mexico","North Dakota","Ohio","Oklahoma","Pennsylvania","Tennessee","Vermont","West Virginia")) %>% data.frame(.)
  })
  
  # Create dataframe for the Scatterplot Tab
  df3 <- eventReactive(input$click3, {
    tdf = df_scatter <- query(
      data.world(propsfile="www/.data.world"),
      dataset="achou/s-17-dv-final-project", type="sql",
      query="
      select AreaName as State, gini_index, ap_cs_2013_states_clean.attempt_rate_black, ap_cs_2013_states_clean.attempt_rate_hispanic
      from `acs-2015-5-e-income-queried.csv/acs-2015-5-e-income-queried`
      left join `ap_cs_2013_states_clean.csv/ap_cs_2013_states_clean`
      where `acs-2015-5-e-income-queried`.AreaName = `ap_cs_2013_states_clean`.state
      "
    ) %>% data.frame(.)
    })  
  
  # Create dataframe for Crosstab KPI Parameters Tab
  df4 <- eventReactive(input$click4, {
    query(
      data.world(propsfile = "www/.data.world"),
      dataset="jadyzeng/s-17-dv-project-5", type="sql",
      query="
      select inc5000_2016_clean.state_l as `State`, 
      inc5000_2016_clean.yrs_on_list as `Years`,
      sum(inc5000_2016_clean.growth) / 100 as `KPI_Growth`,
      case
      when sum(inc5000_2016_clean.growth) / 100 < ? then '03 Low'
      when sum(inc5000_2016_clean.growth) / 100 < ? then '02 Medium'
      else '01 High'
      end AS `kpi`
      from inc5000_2016_clean
      inner join income_census
      on inc5000_2016_clean.state_s = income_census.State
      group by inc5000_2016_clean.state_s, yrs_on_list
      order by inc5000_2016_clean.state_s, yrs_on_list",
      queryParameters = list (KPI_Low(),KPI_Medium(),KPI_High())
    )  %>% data.frame() 
  })
  
  # Create dataframe for Barchart Visualization 1
  df5 <- eventReactive(input$click5, {
      tdf = query(
        data.world(propsfile = "www/.data.world"),
        dataset="jadyzeng/s-17-dv-project-6", type="sql",
        query="SELECT inc5000_2016_clean.industry AS Industry, 
              income_census.State as State, 
              AVG(inc5000_2016_clean.growth) AS AVG_Growth
              From inc5000_2016_clean 
              left outer join income_census
              on inc5000_2016_clean.state_s = income_census.State
              where income_census.State in ('CA','FL','GA','NY','TX')
              AND ((inc5000_2016_clean.industry in ('Construction','Financial Services', 'Health','Human Resources', 'IT Services'))
              OR (inc5000_2016_clean.industry LIKE '%Business Products%'))
              GROUP BY income_census.State,inc5000_2016_clean.industry
              ORDER BY inc5000_2016_clean.industry, income_census.State;"
      ) 
      tdf2 = tdf %>% group_by(Industry) %>% summarize(window_avg_growth = mean(AVG_Growth))
      dplyr::inner_join(tdf, tdf2, by = "Industry")
    })
  
  df6 <- eventReactive(input$click5, {
      tdf6 = query(
      data.world(propsfile = "www/.data.world"),
      dataset="jadyzeng/s-17-dv-project-6", type="sql",
      query = "SELECT inc5000_2016_clean.yrs_on_list, 
            income_census.State as State, 
            AVG(inc5000_2016_clean.revenue) AS AVG_Revenue
            FROM inc5000_2016_clean LEFT OUTER JOIN income_census
            ON inc5000_2016_clean.state_s = State
            WHERE State in ('CA','FL','GA','NY','TX')
            Group by yrs_on_list, income_census.State"

    )
    tdf7 = tdf6 %>% group_by(State) %>% summarize(window_avg_revenue = mean(AVG_Revenue))
    dplyr::inner_join(tdf6, tdf7, by = "State")
  })

  # Create dataframe for Choropleth Map
  df7 <- eventReactive(input$click6,{
      tdf = query(
        data.world(propsfile="www/.data.world"),
        dataset="achou/s-17-dv-final-project", type="sql",
        query="SELECT * FROM `acs-2015-5-e-income-queried.csv/acs-2015-5-e-income-queried`"
      ) %>% data.frame(.)
  })

  
  # ------------------------------------Output data tables for each visualization--------------------------
  
  output$boxplotData1 <- renderDataTable({DT::datatable(df1(), rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE) )
  })
  
  output$histogramData1 <- renderDataTable({DT::datatable(df2(), rownames = FALSE,
                                                          extensions = list(Responsive = TRUE, FixedHeader = TRUE) )
  })
  
  output$scatterData1 <- renderDataTable({DT::datatable(df3(), rownames = FALSE,
                                                          extensions = list(Responsive = TRUE, FixedHeader = TRUE))
  })
  
  output$crosstabData1 <- renderDataTable({DT::datatable(df4(), rownames = FALSE, 
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE))}
  )
  
  output$barchartData1 <- renderDataTable({DT::datatable(df5(), rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE) )
  })
  output$barchartData2 <- renderDataTable({DT::datatable(df6(), rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE) )
  })
  output$choroData1 <- renderDataTable({DT::datatable(df7(), rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE) )
  })
  
  #--------------------------------------------Plot visualizations-------------------------------------------
  
  #-----------------Begin Boxplot Visualization----------------
  output$boxplotPlot1 <- renderPlot({
    #View(dfbp3())
    Plot1 <- ggplot(df1()) + 
      geom_boxplot(aes(x=Region, y=Yield, colour=Region)) + 
      theme(axis.text.x=element_text(angle=90, size=10, vjust=0.5))+
      labs(y = "Yield per Teacher")
    print(Plot1)
  })  

  #-----------------Begin Histogram Visualization--------------
  output$histogramPlot1 <- renderPlot({
    plot_hist_coastal <- ggplot(df_coastal())+
      geom_histogram(aes(x=factor(SCORE), y=COUNT, fill=factor(SCORE)), stat="identity")+
      scale_fill_brewer(type="div", palette="RdYlBu") +
      guides(fill=FALSE) +
      labs(x = "Test Score", y = "Count", 
           title="Score Distribution for Coastal States") +
      theme(title = element_text(size=12, face = "bold"))
    
    plot_hist_landlock <- ggplot(df_landlock())+
      geom_histogram(aes(x=factor(SCORE), y=COUNT, fill=factor(SCORE)), stat="identity") +
      scale_fill_brewer(type="div", palette="RdYlBu")+
      guides(fill=FALSE) +
      labs(x = "Test Score", y = "Count", 
           title = "Score Distribution for Landlocked States") +
      theme(title = element_text(size=12, face = "bold"))
    
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(3,2)))
    vplayout <- function(x,y) viewport(layout.pos.row = x, layout.pos.col = y)
    print(plot_hist_coastal, vp=vplayout(1:3,1))
    print(plot_hist_landlock, vp=vplayout(1:3,2))
  })
  
  #----------------Begin Scatter Plot Visualization------------
  output$scatterPlot1 <- renderPlot({
    plot_scatter <- ggplot(df3()) +
      geom_point(aes(x = gini_index, y = attempt_rate_black, colour="Black"))+
      geom_smooth(aes(x = gini_index, y = attempt_rate_black, colour = "Black"), method = "loess", se = F) +
      geom_point(aes(x = gini_index, y = attempt_rate_hispanic, colour="Hispanic"))+
      geom_smooth(aes(x = gini_index, y = attempt_rate_hispanic, colour="Hispanic"), method = "loess", se = F) +
      labs(title="Influence of Income Inequality on Black and Hispanic Attempt Rate", x = "Gini Index", y="Attempt Rate", colour="Race") +
      scale_colour_manual(values = c(Black = "orange", Hispanic = "turquoise")) +
      theme_classic() +
      theme(panel.background = element_rect(fill="gray10"),
            panel.grid.major = element_line(colour="gray25"))
    print(plot_scatter)
  })
  
  #----------------Begin Crosstab KPI Parameters Visualization- 
  output$crosstabPlot1 <- renderPlot({ggplot(df4()) + 
      theme_light()+
      theme(axis.text.x=element_text(size=10, vjust=0.5), axis.title.x=element_text(size=13)) + 
      theme(axis.text.y=element_text(size=10, hjust=0.5), axis.title.y=element_text(size=13)) +
      geom_text(aes(x=Years, y=State, label=sprintf("%0.2f", round(KPI_Growth, digits = 2))), size=4) +
      geom_tile(aes(x=Years, y=State, fill=kpi), alpha=0.50, color = "gray") + 
      scale_x_continuous(breaks=seq(1, 13, 1)) +
      labs(fill = "Level of Growth", x = "Years on Inc. 5000 List")
  })
  
  #----------------Begin Barchart Visualization---------------
  
  
  #----------------Begin Barchart Visualization---------------
  output$choroMap1 <- renderPlot({
  df_choroMap <- subset(df7(), select = c(AreaName, gini_index))
  colnames(df_choroMap) <- c("region", "value")
  df_choroMap$region <- tolower(df_choroMap$region)
  plot_map <- state_choropleth(df_choroMap, title="Income Inequality in the U.S.", legend="Gini Index")
  print(plot_map)
  })
  
  
  # End Barchart Tab ___________________________________________________________
})