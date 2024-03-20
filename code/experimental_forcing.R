library(tidyverse)

## Recovery of short wave fluxes
## 2-6 year (Tabor et al. 2020) CESM
## 3-5 year (Senel et al. 2022) paleoEarth
## 0-9 year (Bardeen et al. 2017) CESM, soot only
## 0-10 year (Kaiho et al. 2016) MRI, soot only

## parameter x: beginning of recovery (0-3 year)
## parameter k: fully recovery time (2-10 years)

logistic <- function(x,l=1, k=1, x0=0){
  ## l, maximum value
  ## k, steepness, recovery speed
  ## x0, midpoint, recovery year
  exponent <- -1 * k * (x-x0)
  y <- l/(1+exp(exponent))
  ## a scale function from (0.5, 1) to (0, 1)
  ## y <- 2*y - 1
  return(y)
}

x0_samples <- c(2,3,4,5)
k_sample <- c(1,2,5) #indicates 10,6,2 years 


## generate data based on parameter combinations
i = 2
x <- seq(1, 10, by=0.1)
d <- list()
for (xi in x0_samples) {
  for (kj in k_sample){
    y = logistic(x,k=kj,x0=xi)
    origin = data.frame(x=1,y=1,xi=xi,kj=kj)
    d[[i]] = rbind(origin, data.frame(x,y,xi,kj))
    i = i+1
  }
}
d <- do.call("rbind", d)
names(d) <- c("x","y","x0","k")

## visualise the data
p <- ggplot(d,aes(x,y)) + geom_line(aes(color=factor(x0), lty = factor(k)),linewidth=1)  +
  scale_color_viridis_d() + theme_linedraw()
p <- p + xlab("Years after the impact") + ylab('Solar radiation ratio')
ggsave("output/experimental_forcings.png", p, height=7, width=7)


### export data to ASCII file
## filter integer year only
is_int <- function(x){
  if (x %% 1 == 0) {
    return(TRUE)
  } else{
    return(FALSE)
  }
}

d_export <- d %>% filter(map_vec(x, is_int)) %>% filter(y!=1)

## scale y axis to real solar constant
masstrichtian_solar_const <- 1360.33 #W/m2
d_export <- d_export %>% mutate(y=y*masstrichtian_solar_const)
d_export <- d_export %>% round(2)

fill_rows <- function(data, x1,x2){
  additional_tbl <- tibble(x = x1:x2, y = masstrichtian_solar_const)
  return(rbind(data, additional_tbl))
}

export_file <- function(f=d_export, a, b, file_name){

  tmp <- f %>% filter(x0==a & k==b) %>%
    select(x,y) %>%
    mutate(x = x+100)
  
  tmp <- fill_rows(tmp, 1, 100)
  tmp <- fill_rows(tmp, 111, 200)
  
  tmp %>% arrange(x) %>% write_delim(., file_name, delim=" ", col_names = FALSE)
}

add_data_to_file <- function(file_name) {
  # read the existing file into a variable
  file_contents <- readLines(file_name)
  
  # prepend the start marker to the beginning of the file
  file_contents <- c("-START-OF-DATA-", file_contents)
  
  # append the end marker to the end of the file
  file_contents <- c(file_contents, "-END-OF-DATA-")
  
  # write the modified file back to disk
  writeLines(file_contents, file_name)
}


for (xi in x0_samples) {
  for (k in k_sample){
    fname <- paste0("data/genie_solar_constant", "x", xi, "k", k,".txt")
    ## export data
    export_file(f=d_export, a=xi, b=k, file_name = fname)
    ## modify format into GENIE time series
    add_data_to_file(fname)
  }
}

