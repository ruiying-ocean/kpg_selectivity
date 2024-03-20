library(tidyverse)
library(ggpubr)

## find experiments data
find_files <- function(dir_pattern = "muffin.u067bc.PO4.8P8Z.EXP1", fname) {
  dirs <- list.dirs("model", recursive = FALSE)
  matching_dirs <- grep(dir_pattern, dirs, value = TRUE)
  
  if (length(matching_dirs) == 0) {
    stop("No directories found that match the pattern.")
  }
  
  matching_files <- list.files(matching_dirs, pattern = fname, recursive = TRUE, full.names = TRUE)
  
  if (length(matching_files) == 0) {
    stop("No files found that match the pattern.")
  }
  
  return(matching_files)
}

## add heading to the table
better_heading <- function(file){
  header_string <- read_lines(file, n_max=1)
  better_name <- str_split_1(header_string, pattern = " / ")
  better_name[1] <- "time"
  better_name <- c(better_name, "experiment")
  return(better_name)
}

## the core function: read those data
read_files <- function(file_list) {
  data_list <- lapply(file_list, function(f) {
    data <- read.table(f, skip = 1)
    model_name <- dirname(dirname(f))
    data$experiment <- str_split_i(model_name, pattern = "\\.", -1)
    return(data)
  })
  
  data <- do.call(rbind, data_list)
  
  names(data) <- better_heading(file_list[1])
  
  return(data)
}

## a wrapper, read data as a table
read_timeseries <- function(dir,file){
  ## read data
  data = find_files(dir_pattern = dir, fname=file) %>% read_files()
  return(data)
}

read_exp <- function(exp_name){
  ## read data
    ocn_ph <- read_timeseries(exp_name, "biogem_series_misc_surpH.res")
    ocn_d13C <- read_timeseries(exp_name, "biogem_series_ocn_DIC_13C.res") %>%
        mutate(`surface - benthic DIC_13C (o/oo)` = `surface DIC_13C (o/oo)` - `benthic [> 2000 m] DIC_13C (o/oo)`)
    ocn_temp <- read_timeseries(exp_name, "biogem_series_ocn_temp.res")
    ocn_poc_flux <- read_timeseries(exp_name, "biogem_series_fexport_POC.res")
    ## ocn_alk <- read_timeseries(exp_name, "biogem_series_ocn_ALK.res")
    ## ocn_overturning <- read_timeseries(exp_name, "biogem_series_misc_opsi.res")
    ocn_swflux <- read_timeseries(exp_name, "biogem_series_misc_ocn_swflux.res")
    atm_co2 <- read_timeseries(exp_name, "biogem_series_atm_pCO2.res")

    ## create a list of data
    data_list <- list(ocn_ph, ocn_d13C, ocn_temp, ocn_poc_flux, ocn_swflux, atm_co2)
    ## merge data
    complete_data <- Reduce(merge, data_list)
  return(complete_data)
}

## summarize experiments
exp_mean <- function(data) {
  data =  pivot_longer(data, cols = `mean ocean surface pH`:`global pCO2 (atm)`, names_to = "variable")
  data = data %>%
    group_by(time, variable) %>%
    summarize(mean_value = mean(value, na.rm = TRUE),
              lower_ci = quantile(value, 0.05, na.rm = TRUE),
              upper_ci = quantile(value, 0.95, na.rm = TRUE))
  return(data)
}

theme_set(theme_bw())

# var_atm_co2 <- "global pCO2 (atm)"
# var_ocn_swflux <- "mean annual Sw flux at ocean surface (W m-2)"
# var_ocn_temp <- "_surT (C)"
# var_ocn_ph <- "mean ocean surface pH"
# var_ocn_d13C <- "delta_13C"
# var_ocn_poc_flux <- "global POC flux (mol yr-1)"
# var_ocn_overturning <- "global max overturning (Sv)"

exp1 <- read_exp("muffin.u067bc.PO4.8P8Z.EXP1") %>% mutate(label="solar effect")
exp2 <- read_exp("muffin.u067bc.PO4.8P8Z.EXP2") %>% mutate(label="CO2 effect")
exp3 <- read_exp("muffin.u067bc.PO4.8P8Z.EXP3") %>% mutate(label="both")
exp_all <- do.call(rbind, list(exp1, exp2, exp3))

exp_all %>% write_csv("data/kpg_exps.csv")

## convert to long format
exp_all <- pivot_longer(exp_all, cols = `mean ocean surface pH`:`global pCO2 (atm)`, names_to = "variable")

exp_all <- exp_all %>% filter(variable != "global pCO2 (mol)" &
                     variable != "_surT (ice-free) (C)" &
                       variable != "surface (ice-free) DIC_13C (o/oo)"&
                       variable != "global total DIC_13C (mol)" &
                       variable != "global DIC_13C (o/oo)" &
                       variable != "global POC DOM fraction" &
                       variable != "global POC density (mol m-2 yr-1)" &
                       variable != "mean annual Sw flux at ocean surface (W m-2)" &
                       variable != "global pCO2 (atm)")

exp_all <- exp_all %>%
  mutate(variable = replace(variable, variable == "_benT (C)", "Ocean benthic temperature (°C)")) %>%
  mutate(variable = replace(variable, variable == "_surT (C)", "Ocean surface temperature (°C)")) %>%
  mutate(variable = replace(variable, variable == "temperature (C)", "Surface temperature (°C)"))

plot_data <- function(data) {
  data$variable = factor(data$variable, 
                         levels=c(
                                  'Ocean surface temperature (°C)',
                                  'Ocean benthic temperature (°C)',
                                  'Surface temperature (°C)',
                                  'mean ocean surface pH',
                                  'surface DIC_13C (o/oo)',
                                  'benthic DIC_13C (o/oo)',
                                  'surface - benthic DIC_13C (o/oo)',
                                  'global POC flux (mol yr-1)'
                                  ))
  p <- data %>% 
    ggplot(aes(x = time)) +
    geom_line(aes(y=mean_value, color=label), linewidth=0.7)+
    geom_ribbon(aes(ymin=upper_ci, ymax=lower_ci, fill=label), alpha=0.2)+
    facet_wrap(~variable, scales = "free_y", nrow=2)

  p <- p + theme(legend.direction = "horizontal", 
                 legend.box = "horizontal",
                 legend.position = "bottom")
  return(p)
}

colorBlindBlack3  <- c("#E69F00", "#56B4E9","#CC79A7")
library(ghibli)

## adjust the font size for publication
theme_set(theme_bw(base_size = 15))

exp_all %>% mutate(time=time-100) %>%
  plot_data()+scale_fill_manual(values = colorBlindBlack3)+
  scale_color_manual(values=colorBlindBlack3) +
  labs(x="Years after the impact", y="")

ggsave("output/kpg_impacts.png", height=8, width=12, dpi=300)
