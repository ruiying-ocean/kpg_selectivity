library(tidyverse)
library(ncdf4)
library(matrixStats)
library(ggsci)

theme_set(theme_bw())
sst <- read_delim("data/MAASTRICHTIAN_SST_TABOR_2016.txt")
sst <- sst %>% rename(sigma = "Proxy Uncertain (+/-)", sst="Proxy Temp",
                      lat = "Paleo Lat", lon="Paleo Lon")
p <- ggplot()+geom_point(data=sst, aes(x=lat, y=sst,color=Type))
p <- p +  geom_errorbar(data=sst, aes(x=lat, ymin=sst-sigma, ymax=sst+sigma, color=Type), width=.2)
p <- p+ scale_color_nejm()

nc <- nc_open("model/20230324.u067bc.PO4.8P8Z.SPIN/biogem/fields_biogem_2d.nc")
model_sst <- ncvar_get(nc, varid = "ocn_sur_temp")
nc_close(nc)
model_sst <- model_sst[,,13]

## dims 1 -> longitude
## index 0 -> southern ocean
zonal_mean_sst <- colMeans(model_sst, na.rm = T, dims = 1)
zonal_mean_sst[1] = NA
zonal_sd_sst  <- colSds(model_sst, na.rm=T)

genie_lat <- read_csv("data/genie_lat.csv", col_names = "lat")

model_sst <- tibble(genie_lat, zonal_mean_sst, zonal_sd_sst) %>% mutate(sst_min = zonal_mean_sst-zonal_sd_sst,
                                                                        sst_max = zonal_mean_sst+zonal_sd_sst)
model_sst <- model_sst %>% drop_na()

p <- p + geom_line(data=model_sst, aes(x=lat, y=zonal_mean_sst), linewidth=1)
 
p <- p + geom_ribbon(data= model_sst, aes(x=lat, ymin=sst_min, ymax=sst_max), fill="grey", alpha=.3) 

p <- p + labs(x="Latitude (N)", y="SST")
ggsave("output/kpg_sst.png", p, width = 8, height = 5)
p
