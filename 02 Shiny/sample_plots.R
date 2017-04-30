require(ggplot2)
require(dplyr)
require(data.world)
require(readr)
require(DT)
require(plotly)
require(choroplethr)
require(choroplethrAdmin1)
require(acs)
require(grid)
require(gridExtra)
require(RColorBrewer)

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
print(plot_hist_landlock)
grid.newpage()
pushViewport(viewport(layout = grid.layout(3,2)))
vplayout <- function(x,y) viewport(layout.pos.row = x, layout.pos.col = y)
print(plot_hist_coastal, vp=vplayout(1:3,1))
print(plot_hist_landlock, vp=vplayout(1:3,2))