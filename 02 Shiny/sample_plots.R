require(ggplot2)
require(dplyr)
require(data.world)
require(readr)
require(DT)
require(plotly)
require(choroplethr)
require(choroplethrAdmin1)
require(acs)

df_all <- query(
  data.world(propsfile="www/.data.world"),
  dataset="achou/s-17-dv-final-project", type = "sql",
  query="
  select *
  from ap_cs_2013_states_clean
  order by ap_cs_2013_states_clean.state"
) %>% data.frame(.)

plot1 <- ggplot(df_all) +
  geom_line(aes(x=total_takers, y = percent_passed))+
  geom_point(aes(x = total_takers, y = percent_passed, colour=state)) +
  guides(colour = FALSE)

#print(plot1)

df_hist <- query(
  data.world(propsfile="www/.data.world"),
  dataset="achou/s-17-dv-final-project", type="sql",
  query="
  select StateScoreCounts.SCORE, sum(StateScoreCounts.COUNT)
  from StateScoreCounts
  group by StateScoreCounts.SCORE
  order by StateScoreCounts.SCORE"
) %>% data.frame(.)

plot_hist <- ggplot(df_hist)+
  geom_hist(aes(x=SCORE, y=COUNT), stat="identity")

print(plot_hist)