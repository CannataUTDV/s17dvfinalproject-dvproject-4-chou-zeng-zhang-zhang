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


Crosstab <- query(
  data.world(propsfile = "www/.data.world"),
  dataset="achou/s-17-dv-final-project", type="sql",
  query="SELECT StateScoreCounts.SCORE,`acs-2015-5-e-income-queried`.AreaName, StateScoreCounts.COUNT,
avg(`acs-2015-5-e-income-queried`.per_capita_income) as avg_per_capita, 
  case
  when avg(`acs-2015-5-e-income-queried`.per_capita_income) < ? then '03 Low'
  when avg(`acs-2015-5-e-income-queried`.per_capita_income) < ? then '02 Medium'
  else '01 High'
  end AS kpi
  FROM StateScoreCounts LEFT OUTER JOIN `acs-2015-5-e-income-queried`
  ON StateScoreCounts.STATE = `acs-2015-5-e-income-queried`.AreaName
  GROUP BY StateScoreCounts.SCORE,`acs-2015-5-e-income-queried`.AreaName, StateScoreCounts.COUNT
  ORDER BY StateScoreCounts.SCORE,`acs-2015-5-e-income-queried`.AreaName, StateScoreCounts.COUNT
  "
)  %>% data.frame(.) #%>% View()

BarChart <- query(
  data.world(propsfile = "www/.data.world"),
  dataset="achou/s-17-dv-final-project", type="sql",
  query="SELECT state_table.census_region_name, ap_cs_2013_states_clean.state, `acs-2015-5-e-income-queried`.median_household_income,
avg(ap_cs_2013_states_clean.percent_passed) as avg_PassedRate,
  
  case
  when avg(ap_cs_2013_states_clean.percent_passed) < ? then '03 Low'
  when avg(ap_cs_2013_states_clean.percent_passed) < ? then '02 Medium'
  else '01 High'
  end AS kpi
  
  from ap_cs_2013_states_clean left outer join state_table 
  on ap_cs_2013_states_clean.state = state_table.name
  left outer join `acs-2015-5-e-income-queried` 
  on ap_cs_2013_states_clean.state = `acs-2015-5-e-income-queried`.AreaName
  GROUP BY state_table.census_region_name, ap_cs_2013_states_clean.state, `acs-2015-5-e-income-queried`.median_household_income
  ORDER BY state_table.census_region_name, ap_cs_2013_states_clean.state, `acs-2015-5-e-income-queried`.median_household_income
  "
)  %>% data.frame(.) 


BoxPlot <- query(
  data.world(propsfile = "www/.data.world"),
  dataset="achou/s-17-dv-final-project", type="sql",
  query="select state_table.census_region_name as Region, ap_cs_2013_states_clean.yield_per_teacher as Yield 
from state_table left outer join ap_cs_2013_states_clean
  on state_table.name=ap_cs_2013_states_clean.state"
)  %>% data.frame(.)

Plot1 <- ggplot(BoxPlot) + 
  geom_boxplot(aes(x=Region, y=Yield, colour=Region)) + 
  theme(axis.text.x=element_text(angle=90, size=10, vjust=0.5))
print(Plot1)
