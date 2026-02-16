# K-Pg Ocean Ecosystem

This repository contains plotting scripts and data for analysing the marine ecosystem response to the Cretaceous-Paleogene (K-Pg) mass extinction event (~66 Ma), modelled using the cGENIE Earth System Model with the EcoGEM ecological module.

## Repository Structure

```
├── code/       # Analysis scripts and Jupyter notebooks
├── data/       # Model forcing files and observational data
├── model/      # cGENIE experiment outputs (see Data section)
```

## Code

| Script | Description |
|--------|-------------|
| `create_forcing.py` | Generates solar constant forcing for the impact winter scenario |
| `concept.ipynb` | Trait-based plankton framework (allometric relationships) |
| `plot_fig3.ipynb` | Geographic extinction maps  (Fig. 3)|
| `plot_timeseries.ipynb` | Biomass, productivity, and biogeochemistry evolution |
| `plot_maps.ipynb` | Environmental change maps (SST, pH, nutrients) |
| `plot_diversity_timeseries.ipynb` | Plankton richness evolution |
| `plot_Danian.ipynb` | Post-extinction recovery dynamics |
| `plot_createceous_climate.ipynb` | Pre-impact climate baseline |
| `plot_photoacclimation.ipynb` | Light adaptation responses |
| `sensitivity_experiment.ipynb` | Isolating individual extinction drivers (solar, CO2, SST, light) |
| `plot_threshold_sensitivity.ipynb` | Extinction threshold sensitivity |
| `plot_alternative_extinction_threshold.ipynb` | Robustness of extinction criteria|
| `plot_lat_selectivity.ipynb` | Latitude-dependent extinction patterns (Fig 4) |
| `MLD_vs_CLIMBER.ipynb` | Validating the model's mixed layer depth |
| `modern_model.ipynb` | Validate the modern ocean  circulation |

## Data

The cGENIE model output is archived on Zenodo: [10.5281/zenodo.17742290](https://doi.org/10.5281/zenodo.17742290). Download and place the experiment directories under `model/`.

## Dependencies

**Python**
- [cgeniepy](https://github.com/ruiying-ocean/cgeniepy) — cGENIE model interface
- xarray, numpy, pandas
- matplotlib, cartopy, seaborn
- cmcrameri, cmocean, palettable (colormaps)
