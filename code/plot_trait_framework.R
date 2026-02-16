library(tidyverse)
library(patchwork)
library(tidyplots)

# load data
setwd("~/science/kpg_ecosystem")
traits <- read_csv("output/trait_df.csv")

# pretty strip titles
pretty_titles <- c(
  volume    = "Volume",
  q_C       = "Cellular carbon",
  vmax_C    = "Max photosynthesis rate"  ,
  vmax_PO4  = "Max PO4 uptake rate"
)

traits_long <- read_csv("output/trait_df.csv") %>%
  select(PFT, diameter, volume, vmax_C, q_C, vmax_PO4) %>%
  pivot_longer(
    cols      = c(volume, vmax_C, q_C, vmax_PO4),
    names_to  = "trait",
    values_to = "value"
  ) %>%
  mutate(trait = factor(trait,
                        levels = c("volume", "q_C","vmax_C", "vmax_PO4"),
                        labels = pretty_titles
  ))


p <- traits_long |>
  tidyplot(x = diameter, y = value, color = PFT) |>
  add_line(linewidth = .5) |>
  add_data_points(shape=4) |>
  adjust_size(width = 40, height = 40) |>
  theme_tidyplot(fontsize = 12) |>
  remove_x_axis_title() |>            # ← remove per-panel x titles  [oai_citation:0‡cran.r-universe.dev](https://cran.r-universe.dev/tidyplots/doc/manual.html)
  split_plot(by = trait, ncol = 2, nrow = 2)

# now add one shared x axis label and save
p & labs(x = "Diameter (μm)") -> p2
save_plot(p2, "output/trait_framework.pdf")
s