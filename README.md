# K-Pg Ocean Ecosystem

This repository contains plotting scripts and data for analysing the marine ecosystem response to the Cretaceous-Paleogene (K-Pg) mass extinction event (~66 Ma), modelled using the cGENIE Earth System Model with the EcoGEM ecological module.

## Repository Structure

```
├── code/       # Analysis scripts and Jupyter notebooks (see code/README.md)
├── data/       # Model forcing files and observational data (see data/README.md)
├── model/      # cGENIE experiment outputs (Zenodo: 10.5281/zenodo.17742290)
```

## Dependencies

**Python**
- [cgeniepy](https://github.com/ruiying-ocean/cgeniepy) — cGENIE model interface
- xarray, numpy, pandas
- matplotlib, cartopy, seaborn
- cmcrameri, cmocean, palettable (colormaps)
