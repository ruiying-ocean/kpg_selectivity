library(tidyverse)
library(scales)

# load data from WebplotDigit measurement
cool_forcing <- read_csv("data/cooling_forcing.csv")
# Note that visible transmission ratio is not direct transmission level
cool_forcing <- cool_forcing %>% mutate(transmission_ratio = 1 - Cooling_Forcing/max(Cooling_Forcing))

# reproduce the figure 2a in PIERAZZO et al. 2003 Astrobiology, 3(1), 99–118,
p1 <- cool_forcing %>% ggplot(aes(x=Year_after_KPg, y=`Cooling_Forcing`)) + geom_line(aes(lty=Group))
p1 <- p1 +  scale_y_continuous(trans = 'log')+annotation_logticks(sides="l")
p1 <- p1 + scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                       labels = trans_format("log10", math_format(10^.x)))
p1 <- p1 + scale_x_continuous(breaks = seq(0, 16, by=2))
p1 <- p1 + labs(x="Years after K-Pg boundary", y="Cooling Radiative Forcing")
p1 <- p1+theme_bw()
ggsave("output/cooling_forcing_PIERAZZO_2003.png", p1, width = 7, height = 5)
# reproduce the figure 2b
p2 <- cool_forcing %>% ggplot(aes(x=Year_after_KPg, y=transmission_ratio*0.75)) + geom_line(aes(lty=Group)) + ylim(c(0,.9))
p2 <- p2 + theme_bw() + labs(x="Years after K-Pg boundary", y="Visible Transmission")

end_cretaceous_solar_constant <- 1360.33 #W/m2
export_to_genie <- cool_forcing %>% mutate(genie_solar_constant = end_cretaceous_solar_constant * transmission_ratio)
export_to_genie <- export_to_genie %>% filter(Year_after_KPg%%1 == 0) %>% select(Year_after_KPg, genie_solar_constant)

add_forcing_rows <- function(y1, y2, data_to_export=export_to_genie){
  additional_tbl <- tibble(Year_after_KPg = y1:y2, genie_solar_constant = end_cretaceous_solar_constant)
  return(rbind(data_to_export,additional_tbl))
}

export_to_genie <- add_forcing_rows(1, 200)

#export_to_genie <- export_to_genie %>% mutate(Year_after_KPg = Year_after_KPg - 0.5)

export_to_genie  %>% round(2) %>%  write_delim(., "data/genie_solar_constant.txt", delim=" ")

### ensemble parameters for simulation
# x <- 1:100
# k <- c(0.5, 0.6, 0.7, 0.8, 0.9, 1.0)
# f <- function(x,k){
#   return(1-1/x**k)
# }
# 
# df <- cbind(x, f(x,k[1]), f(x,k[2]), f(x,k[3]), f(x,k[4]),
#             f(x,k[5]), f(x,k[6])) |> data.frame()
# 
# df %>% pivot_longer(cols = V2:V7) %>% ggplot(aes(x=x,y=value)) + geom_line(aes(color=name))
