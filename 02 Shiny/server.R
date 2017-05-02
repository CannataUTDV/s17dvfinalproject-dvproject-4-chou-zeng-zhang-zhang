# server.R
require(ggplot2)
require(dplyr)
require(shiny)
require(shinydashboard)
require(data.world)
require(DT)
require(grid)
require(gridExtra)
require(RColorBrewer)
require(acs)
require(choroplethr)
require(choroplethrAdmin1)
require(choroplethrMaps)
require(reshape2)

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
  
  # Create dataframe for the BoxPlot Tab
  df1 <- eventReactive(input$click1, {
    BoxPlot <- query(
      data.world(propsfile = "www/.data.world"),
      dataset="achou/s-17-dv-final-project", type="sql",
      query="
      SELECT state_table.name AS State, 
      state_table.census_region_name AS Region, 
      ROUND(ap_cs_2013_states_clean.yield_per_teacher, 2) AS Yield
      FROM state_table LEFT OUTER JOIN ap_cs_2013_states_clean
      ON state_table.name=ap_cs_2013_states_clean.state
      "
    )  %>% data.frame(.)
    })
  
  # Create dataframe for the Histogram Tab
  df2 <- eventReactive(input$click2, {df_hist})
  
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
      SELECT AreaName AS State, gini_index, 
      ROUND(ap_cs_2013_states_clean.attempt_rate_black, 2) AS attempt_rate_black,
      ROUND(ap_cs_2013_states_clean.attempt_rate_hispanic, 2) AS attempt_rate_hispanic
      FROM `acs-2015-5-e-income-queried.csv/acs-2015-5-e-income-queried`
      LEFT JOIN `ap_cs_2013_states_clean.csv/ap_cs_2013_states_clean`
      WHERE `acs-2015-5-e-income-queried`.AreaName = `ap_cs_2013_states_clean`.state
      "
    ) %>% data.frame(.)
    })  
  
  # Create dataframe for Crosstab KPI Parameters Tab
  df4 <- eventReactive(input$click4, {
    query(
      data.world(propsfile = "www/.data.world"),
      dataset="achou/s-17-dv-final-project", type="sql",
      query="
      SELECT StateScoreCounts.SCORE AS Score,
      ap_cs_2013_states_clean.state AS State, 
      StateScoreCounts.COUNT AS Count,
      ROUND(avg(ap_cs_2013_states_clean.percent_passed), 2) AS Percent_Passed, 
      
      case
      when avg(ap_cs_2013_states_clean.percent_passed) < ? then '03 Low'
      when avg(ap_cs_2013_states_clean.percent_passed) < ? then '02 Medium'
      else '01 High'
      end AS kpi

      FROM StateScoreCounts LEFT OUTER JOIN ap_cs_2013_states_clean
      ON StateScoreCounts.STATE = ap_cs_2013_states_clean.state
      GROUP BY StateScoreCounts.SCORE,ap_cs_2013_states_clean.state, StateScoreCounts.COUNT
      ORDER BY StateScoreCounts.SCORE,ap_cs_2013_states_clean.state, StateScoreCounts.COUNT
      ",
      queryParameters = list (KPI_Low(),KPI_Medium())
    )  %>% data.frame()
  })
  
  # Create dataframe for Barchart Tab
  df5 <- eventReactive(input$click5, {
    tdf5 = query(
        data.world(propsfile = "www/.data.world"),
        dataset="achou/s-17-dv-final-project", type="sql",
        query="SELECT  ap_cs_2013_states_clean.state As State,
        ROUND(ap_cs_2013_states_clean.percent_female_taking, 2) AS Female_Taking,
        ROUND(ap_cs_2013_states_clean.percent_black_taking, 2) AS Black_Taking,
        ROUND(ap_cs_2013_states_clean.percent_hispanic_taking, 2) AS percent_hispanic_taking
        From ap_cs_2013_states_clean left outer join `acs-2015-5-e-income-queried`
        on ap_cs_2013_states_clean.state = `acs-2015-5-e-income-queried`.AreaName
        WHERE `acs-2015-5-e-income-queried`.median_household_income > 60000
        "
      ) %>% data.frame(.)
    
    })
  
  tdf6 <- query(
    data.world(propsfile = "www/.data.world"),
    dataset="achou/s-17-dv-final-project", type="sql",
    query="
    SELECT 
    ap_cs_2013_states_clean.state AS State,
    ROUND(ap_cs_2013_states_clean.percent_female_taking, 2) AS Female_Taking,
    ROUND(ap_cs_2013_states_clean.percent_black_taking, 2) AS Black_Taking,
    ROUND(ap_cs_2013_states_clean.percent_hispanic_taking, 2) AS percent_hispanic_taking
    From ap_cs_2013_states_clean left outer join `acs-2015-5-e-income-queried` 
    on ap_cs_2013_states_clean.state = `acs-2015-5-e-income-queried`.AreaName
    WHERE `acs-2015-5-e-income-queried`.median_household_income > 60000
    "
    ) %>% data.frame(.)
            
  df6 <- melt(tdf6)
  

  # Create dataframe for Choropleth Map
  df7 <- eventReactive(input$click6,{
      tdf = query(
        data.world(propsfile="www/.data.world"),
        dataset="achou/s-17-dv-final-project", type="sql",
        query="
        SELECT * 
        FROM `acs-2015-5-e-income-queried.csv/acs-2015-5-e-income-queried`
        "
      ) %>% data.frame(.)
  })

  
  # ---------------Output data tables for each visualization--------------
  
  output$boxplotData1 <- renderDataTable({DT::datatable(df1(), 
                                                        rownames = FALSE,
                                                        extensions = list(Responsive = TRUE, FixedHeader = TRUE)
                                                        )
    })
  
  output$histogramData1 <- renderDataTable({DT::datatable(df2(), 
                                                          rownames = FALSE,
                                                          extensions = list(Responsive = TRUE, FixedHeader = TRUE)
                                                          )
    })
  
  output$scatterData1 <- renderDataTable({DT::datatable(df3(), 
                                                        rownames = FALSE,
                                                        extensions = list(Responsive = TRUE, FixedHeader = TRUE)
                                                        )
    })
  
  output$crosstabData1 <- renderDataTable({DT::datatable(df4(), 
                                                         rownames = FALSE, 
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE)
                                                         )
    })
  
  output$barchartData1 <- renderDataTable({DT::datatable(df5(), 
                                                         rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE) 
                                                         )
    })
  
  output$choroData1 <- renderDataTable({DT::datatable(df7(), rownames = FALSE,
                                                         extensions = list(Responsive = TRUE, FixedHeader = TRUE)
                                                      )
    })
  
  #--------------Plot visualizations--------------------
  
  #-----------------Boxplot----------------
  output$boxplotPlot1 <- renderPlot({
    ggplot(df1()) + 
    geom_boxplot(aes(x=Region, y=Yield, fill=Region), colour="black") + 
    theme(axis.text.x=element_text(angle=90, size=10, vjust=0.5)) +
    guides(fill = F) +
    labs(y = "Test Takers per Teacher") + 
    theme_classic()
  })  

  #-----------------Histogram--------------
  output$histogramPlot1 <- renderPlot({
    plot_hist_coastal <- ggplot(df_coastal())+
      geom_histogram(aes(x=factor(SCORE), y=COUNT, fill=factor(SCORE)), stat="identity")+
      scale_fill_brewer(type="div", palette="RdYlBu") +
      guides(fill=FALSE) +
      labs(x = "Test Score", y = "Count", 
           title="Score Distribution for Coastal States") +
      theme(title = element_text(size=12, face = "bold"),
            panel.background = element_rect(fill="gray20"),
            panel.grid.major = element_line(colour = "gray30"),
            panel.grid.minor = element_line(colour = "gray30")
            )
    
    plot_hist_landlock <- ggplot(df_landlock())+
      geom_histogram(aes(x=factor(SCORE), y=COUNT, fill=factor(SCORE)), stat="identity") +
      scale_fill_brewer(type="div", palette="RdYlBu")+
      guides(fill=FALSE) +
      labs(x = "Test Score", y = "Count", 
           title = "Score Distribution for Landlocked States") +
      theme(title = element_text(size=12, face = "bold"), 
            panel.background = element_rect(fill="gray20"),
            panel.grid.major = element_line(colour = "gray30"),
            panel.grid.minor = element_line(colour = "gray30")
            )
    
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(3,2)))
    vplayout <- function(x,y) viewport(layout.pos.row = x, layout.pos.col = y)
    print(plot_hist_coastal, vp=vplayout(1:3,1))
    print(plot_hist_landlock, vp=vplayout(1:3,2))
  })
  
  #----------------Scatter Plot------------
  output$scatterPlot1 <- renderPlot({
    ggplot(df3()) +
    geom_point(aes(x = gini_index, y = attempt_rate_black, colour="Black"))+
    geom_smooth(aes(x = gini_index, y = attempt_rate_black, colour = "Black"), method = "loess", se = F) +
    geom_point(aes(x = gini_index, y = attempt_rate_hispanic, colour="Hispanic"))+
    geom_smooth(aes(x = gini_index, y = attempt_rate_hispanic, colour="Hispanic"), method = "loess", se = F) +
    labs(title="Influence of Income Inequality on Black and Hispanic Attempt Rates", x = "Gini Index", y="Attempt Rate", colour="Group") +
    scale_colour_manual(values = c(Black = "orange", Hispanic = "turquoise")) +
    theme_classic() +
    theme(panel.background = element_rect(fill="gray10"),
          panel.grid.major = element_line(colour="gray25"))
  })
    
  #----------------Crosstab-------------
  output$crosstabPlot1 <- renderPlot({
    ggplot(df4()) + 
    theme_light() +
    theme(axis.text.x=element_text(size=10, vjust=0.5), axis.title.x=element_text(size=13)) + 
    theme(axis.text.y=element_text(size=10, hjust=0.5), axis.title.y=element_text(size=13)) +
    geom_text(aes(x=Score, y=State, label=Count), size=4) +
    geom_tile(aes(x=Score, y=State, fill=kpi), alpha=0.50, color = "gray") + 
    scale_x_continuous(breaks=seq(1, 13, 1)) +
    labs(fill = "Pass Rate", x = "Score")
  })
  
  #----------------Barchart---------------
  output$barchartPlot1 <- renderPlot({
    ggplot(df6, aes(State, value, fill = factor(variable, labels=c("Female", "Black", "Hispanic")))) +
    theme(axis.text.x=element_text(angle=0, size=12, vjust=0.5)) +
    theme(axis.text.y=element_text(size=12, hjust=0.5)) +
    geom_bar(stat= 'identity', position = 'dodge') +
    coord_flip() +
    geom_text(mapping=aes(State, value,label= sprintf("%2.2f",value)), position = position_dodge(width = 1), colour="black", hjust=-.5)+
    labs(fill = "Group", y = "Percent of Total Test Takers in State")
    })
  
  #----------------Choropleth Map---------------
  output$choroMap1 <- renderPlot({
    df_choroMap <- subset(df7(), select = c(AreaName, gini_index))
    colnames(df_choroMap) <- c("region", "value")
    df_choroMap$region <- tolower(df_choroMap$region)
    state_choropleth(df_choroMap, 
                     title="Income Inequality in the U.S.", 
                     legend="Gini Index"
                     )
    })

})