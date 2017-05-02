require(ggplot2)
require(dplyr)
require(data.world)
require(readr)
require(DT)
require(plotly)
require(choroplethr)
require(choroplethrAdmin1)
require(choroplethrMaps)
require(acs)
require(RColorBrewer)
require(grid)
require(gridExtra)

### Histogram Code
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

df_coastal <- df_hist %>% dplyr::filter(STATE %in% c("Maine", "New Hampshire", "Massachussetts", "Rhode Island", "Connecticut", "New Jersey", "New York", "Delaware", "Maryland", "Virginia", "North Carolina","South Carolina", "Georgia","Florida", "Oregon", "Washington", "Alaska", "Hawaii", "California", "Florida", "Alabama", "Mississippi","Louisiana","Texas")) %>% data.frame(.)

df_landlock <- df_hist %>% dplyr::filter(STATE %in% c("Arizona", "Arkansas", "Washington DC", "Idaho", "Kentucky","Michigan","Minnesota","Montana","Nevada","New Mexico","North Dakota","Ohio","Oklahoma","Pennsylvania","Tennessee","Vermont","West Virginia")) %>% data.frame(.)


plot_hist_coastal <- ggplot(df_coastal)+
  geom_histogram(aes(x=factor(SCORE), y=COUNT, fill=factor(SCORE)), stat="identity")+
  scale_fill_brewer(type="div", palette="RdYlBu") +
  guides(fill=FALSE) +
  labs(x = "Test Score", y = "Count", 
       title="Score Distribution for Coastal States") +
  theme(title = element_text(size=12, face = "bold"))

plot_hist_landlock <- ggplot(df_landlock)+
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
###

### Choropleth Maps
df_census <- query(
  data.world(propsfile="www/.data.world"),
  dataset="achou/s-17-dv-final-project", type="sql",
  query="
  SELECT *
  FROM `acs-2015-5-e-income-queried.csv/acs-2015-5-e-income-queried`
  "
) %>% data.frame(.)

df_choroMap_gini <- subset(df_census, select = c(AreaName, gini_index))
colnames(df_choroMap_gini) <- c("region", "value")
df_choroMap_gini$region <- tolower(df_choroMap_gini$region)
plot_map_gini <- state_choropleth(df_choroMap_gini, title="Income Inequality in the U.S.", legend="Gini Index")

df_choroMap_income <- subset(df_census, select = c(AreaName, median_household_income))
colnames(df_choroMap_income) <- c("region", "value")
df_choroMap_income$region <- tolower(df_choroMap_income$region)
plot_map_income <- state_choropleth(df_choroMap_income, title="Median Income Distribution in the U.S.", legend="Median Household Income (US Dollars)") + scale_color_brewer()


df_choroMap_capita <- subset(df_census, select = c(AreaName, per_capita_income))
colnames(df_choroMap_capita) <- c("region", "value")
df_choroMap_capita$region <- tolower(df_choroMap_capita$region)
plot_map_capita <- state_choropleth(df_choroMap_income, title="Per Capita Income in the U.S.", legend="Per Capita Income (US Dollars)")

grid.newpage()
pushViewport(viewport(layout = grid.layout(3,1)))
vplayout <- function(x,y) viewport(layout.pos.row = x, layout.pos.col = y)
print(plot_map_gini, vp=vplayout(1,1))
print(plot_map_income, vp=vplayout(2,1))
print(plot_map_capita, vp= vplayout(3,1))
###

### Scatterplot
df_scatter <- query(
  data.world(propsfile="www/.data.world"),
  dataset="achou/s-17-dv-final-project", type="sql",
  query="
  select AreaName as State, gini_index, ap_cs_2013_states_clean.attempt_rate_black, ap_cs_2013_states_clean.attempt_rate_hispanic
  from `acs-2015-5-e-income-queried.csv/acs-2015-5-e-income-queried`
  left join `ap_cs_2013_states_clean.csv/ap_cs_2013_states_clean`
  where `acs-2015-5-e-income-queried`.AreaName = `ap_cs_2013_states_clean`.state
  "
) %>% data.frame(.)

plot_scatter <- ggplot(df_scatter) +
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
###
