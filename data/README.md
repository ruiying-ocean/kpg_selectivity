# Data

Model forcing files, observational data, and processed outputs used in the analysis.

## Model output

The cGENIE model output is archived on Zenodo: [10.5281/zenodo.17742290](https://doi.org/10.5281/zenodo.17742290). Download and place the experiment directories under `model/`.

## Forcing files

| File | Description |
|------|-------------|
| `solar_constant.txt` | Solar constant time series for the impact winter scenario |
| `GENIE_preimpact_dust.nc` | Pre-impact dust deposition field (NetCDF) |
| `GENIE_preimpact_dust.txt` | Pre-impact dust deposition field (text) |
| `GENIE_postimpact_dust.nc` | Post-impact dust deposition field |
| `GENIE_po4_deposition.txt` | Phosphate deposition forcing |
| `GENIE_tfe_deposition.txt` | Total iron deposition forcing |
| `Postdam2_dust_pulse.nc` | Post-impact dust pulse scenario (Potsdam) |
| `Postdam2_preimpact_dust.nc` | Pre-impact dust baseline (Potsdam) |

## Model grids and masks

| File | Description |
|------|-------------|
| `GENIE_mask.nc` | GENIE land-sea mask |
| `masked_array.nc` | Custom masked grid for analysis |

## Observational and validation data

| File | Description |
|------|-------------|
| `Tabor_Maastrichtian_proxy.xlsx` | Maastrichtian SST proxy compilation (Tabor et al.) |
| `Hull2020_S10.csv` | Site-level bulk carbonate δ¹³C time series (Hull et al., 2020, Table S10) |
| `Hull2020_S12.csv` | Site-level pre-impact δ¹³C values (Hull et al., 2020, Table S12) |
| `Hull2020_S13.csv` | Bulk δ¹³C composite record (Hull et al., 2020, Table S13) |
| `Zhang2019.csv` | Observational data from Zhang et al. (2019) |
| `ccsm_mld_4xCO2.nc` | CCSM mixed layer depth under 4xCO2 (for MLD validation) |
| `eccov4_mld_clim.nc` | ECCO v4 mixed layer depth climatology (for MLD validation) |

## Processed model output

| File | Description |
|------|-------------|
| `kpg_exps.csv` | Summary of K-Pg experiment configurations |
| `pft_richness.csv` | Plankton functional type richness data |
| `MOC_all_simus.nc` | CCSM4 global meridional overturning circulation (for validation) |
| `muffin.u067bc.PO4.PAR.txt` | Extracted PAR (photosynthetically active radiation) fields |
| `muffin.u067bc.PO4.SST.txt` | Extracted sea surface temperature fields |
| `tfkeoo.pgclann.nc` | HadCM3 annually averaged biogeochemical tracer output (for validation) |
