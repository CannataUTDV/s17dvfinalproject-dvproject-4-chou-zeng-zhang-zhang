# server.R
require(ggplot2)
require(dplyr)
require(shiny)
require(shinydashboard)
require(data.world)
require(readr)
require(DT)
require(plotly)

shinyServer(function(input, output) { 
  
  # Create dataframe for Visualization 1
  df4 <- eventReactive(input$click4, {
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
        #queryParameters = state_l
      )
      tdf2 = tdf %>% group_by(Industry) %>% summarize(window_avg_growth = mean(AVG_Growth))
      dplyr::inner_join(tdf, tdf2, by = "Industry")
    })
  
  df6 <- eventReactive(input$click4, {
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
  #--------------------------
  # Create dataframe for ID Set Visualization ------------------------------------------------------------------
  
  df5 <- eventReactive(input$click4, {
    
    tdf_a <- query(
      data.world(propsfile = "www/.data.world"),
      dataset="jadyzeng/s-17-dv-project-6", type="sql",
      query="
      Select inc5000_2016_clean.id, sum(inc5000_2016_clean.revenue) as SUM_Revenue
      from inc5000_2016_clean
      group by inc5000_2016_clean.id
      having sum(inc5000_2016_clean.revenue) > 1000000000
      order by inc5000_2016_clean.id"
      ) %>% data.frame 
    
    tdf_b <- query(
      data.world(propsfile = "www/.data.world"),
      dataset="jadyzeng/s-17-dv-project-6", type="sql",
      query="
      select id, inc5000_2016_clean.growth AS growth 
      FROM inc5000_2016_clean 
      WHERE id in (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
      order by id",
      queryParameters = tdf_a$id
    ) %>% data.frame
    
  })
  
  # Output data tables for each visualization--------------------------
  output$barchartData1 <- renderDataTable({DT::datatable(df4(),
                                                         rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE) )
  })
  output$barchartData2 <- renderDataTable({DT::datatable(df5(),
                                                         rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE) )
  })
  output$barchartData3 <- renderDataTable({DT::datatable(df6(),
                                                         rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE) )
  })
  
  # Plot visualizations--------------------------
  
  # Begin Visualization #1
  output$barchartPlot1 <- renderPlot({ggplot(df4(), aes(x=State, y=AVG_Growth)) +
      scale_y_continuous(labels = scales::comma) + # no scientific notation
      theme(axis.text.x=element_text(angle=0, size=12, vjust=0.5)) + 
      theme(axis.text.y=element_text(size=12, hjust=0.5)) +
      geom_bar(stat = "identity") + 
      facet_wrap(~Industry, ncol=1) +
      labs(y = "Average Growth over Past 3 Years (Percent)", x = "State") +
      coord_flip() +
      # Add sum_sales, and (sum_sales - window_avg_sales) label.
      geom_text(mapping=aes(x=State, y=AVG_Growth, label=round(AVG_Growth)),colour="black", hjust= -.5) +
      geom_text(mapping=aes(x=State, y=AVG_Growth, label=round(AVG_Growth - window_avg_growth)),colour="blue", hjust= -3) +
      # Add reference line with a label.
      geom_hline(aes(yintercept = round(window_avg_growth)), color="red") +
      geom_text(aes( -1, window_avg_growth, label = round(window_avg_growth), vjust = -.5, hjust = -.25), color="red")
  })
  # End Visualization #1
  
  # Begin Visualization #2
  output$barchartPlot2 <- renderPlotly({
    
    # Using ggplot2
    # p <- ggplot(df5(), aes(x=as.character(id), y=growth)) +
    #   theme(axis.text.x=element_text(size=6, vjust=0.5)) +
    #   theme(axis.text.y=element_text(size=8, hjust=0.8)) +
    #   theme(axis.title.x=element_text(vjust=0)) +
    #   geom_bar(stat = "identity", fill='#1579f4') +
    #   geom_hline(aes(yintercept=mean(growth)), color="navy") +
    #   labs(x="Company ID", y="Percent Growth in 2015")
    # ggplotly(p)
    
    #Using plot_ly
    plot_ly(
      data = df5(),
      x = ~as.character(id),
      y = ~growth,
      type = "bar"
    ) %>%
      layout(
        xaxis = list(title="Company ID", type="category", categoryorder="category ascending", tickfont=list(size=9)),
        yaxis = list(title="Percent Growth (Past 3 Years)")
      )
  })
  # End Visualization #2

  # Begin Visualization #3
  output$barchartPlot3 <- renderPlot({ggplot(df6(), aes(x=yrs_on_list, y=AVG_Revenue)) +
      scale_y_continuous(labels = scales::comma) + # no scientific notation
      theme(axis.text.x=element_text(angle=0, size=10, vjust=0.5)) + 
      theme(axis.text.y=element_text(size=10, hjust=0.5)) +
      geom_bar(stat = "identity") + 
      facet_wrap(~State, ncol=1) + 
      labs(y = "Average Revenue (US Dollars)", x="Years on the List") +
      coord_flip() + 
      # Add sum_sales, and (sum_sales - window_avg_sales) label.
      geom_text(mapping=aes(x=yrs_on_list, y=AVG_Revenue, label=round(AVG_Revenue)),colour="black", hjust=-.5) +
      geom_text(mapping=aes(x=yrs_on_list, y=AVG_Revenue, label=round(AVG_Revenue - window_avg_revenue)),colour="blue", hjust=-2) +
      # Add reference line with a label.
      geom_hline(aes(yintercept = round(window_avg_revenue)), color="red") +
      geom_text(aes( -1, window_avg_revenue, label = round(window_avg_revenue), vjust = -.5, hjust = -.25), color="red")

  })
  # End Visualization #3
  
  # End Barchart Tab ___________________________________________________________
})