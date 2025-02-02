from cgeniepy.ecology import EcoModel
import matplotlib.pyplot as plt
import numpy as np
import xarray as xr
from cgeniepy.array import GriddedData

arc_mask = xr.load_dataarray("/Users/yingrui/science/kpg_ecosystem/masked_array.nc")

def mask_arctic(input_data):
    "apply the new land-sea mask to the data"
    input_data = input_data * arc_mask
    return input_data

def pft_change(model):
    #carbon_thresholds = model.eco_pars()['q_C']

    ## recalculate because foram use a different method
    qcarbon_a = model.get_config('ECOGEM')['qcarbon_a']
    qcarbon_b = model.get_config('ECOGEM')['qcarbon_b']
    volume = model.eco_pars()['volume']
    carbon_thresholds = qcarbon_a * volume ** qcarbon_b

    ## counting from 0
    phyto_index = np.arange(0,32)
    zoo_index = np.arange(32,64)
    mixo_index = np.arange(64,96)
    foram_index = np.arange(96,112)

    ## diversity (no. of PFTs) map

    model_mask = model.grid_mask()

    phyto_rich, zoo_rich, mixo_rich, foram_rich = [], [], [], []

    for i in range(len(carbon_thresholds)):
        pft = model.get_pft(i+1)
        threshold = carbon_thresholds[i]    
        ## filter out the species with biomass less than threshold    
        pft_presence = xr.where(pft> threshold, 1, 0.0)
        if i in phyto_index:
            phyto_rich.append(pft_presence)
        elif i in zoo_index:
            zoo_rich.append(pft_presence)
        elif i in mixo_index:
            mixo_rich.append(pft_presence)
        elif i in foram_index:
            foram_rich.append(pft_presence)

    ## sum over PFT dimension
    phyto_rich = xr.concat(phyto_rich, dim='pft') * model_mask
    zoo_rich = xr.concat(zoo_rich, dim='pft') * model_mask
    mixo_rich = xr.concat(mixo_rich, dim='pft')* model_mask
    foram_rich = xr.concat(foram_rich, dim='pft')*model_mask
    total_pft = phyto_rich.sum(dim='pft') + zoo_rich.sum(dim='pft') +mixo_rich.sum(dim='pft') +foram_rich.sum(dim='pft')

    total_pft = total_pft *model_mask
    total_pft = GriddedData(total_pft, attrs={'long_name': 'Total PFTs',  'units': ''})
    return total_pft

exp3 = EcoModel("model/muffin.u067bc.PO4.EXP3", gemflag=['biogem', 'ecogem'])
total_effect = pft_change(exp3)

pico_frac = exp3.get_var("eco2D_Size_Frac_Pico_Chl")/exp3.get_var("eco2D_Plankton_Chl_Total") * 100
light = exp3.get_var("phys_fxsw")
light_diff = light[3] - light[0]

fig, axs = plt.subplots(1,3, figsize=(7,2), sharex=True, tight_layout=True)
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['font.sans-serif'] = 'Helvetica'

extinction_rate = total_effect[-1]/total_effect[0] * 100

## apply the new mask
extinction_rate = mask_arctic(extinction_rate)
light_diff = mask_arctic(light_diff)
pico_frac = mask_arctic(pico_frac)

axs[0].plot(extinction_rate.lat, extinction_rate.mean(dim='lon'))
axs[1].plot(light_diff.lat, light_diff.mean(dim='lon'))
axs[2].plot(pico_frac[0].lat, pico_frac[0].mean(dim='lon'))

axs[0].set_title('Plankton survivor ratio')
axs[1].set_title('Solar radiation change')
axs[2].set_title('preimpact Pico fraction')

labels = ['a', 'b', 'c']
for i, ax in enumerate(axs.flat):      
    if i == 1:
        ax.set_ylabel('W/m$^2$')
    else:
        ax.set_ylabel('%')    

    ax.text(0.1, .9, labels[i], transform=ax.transAxes, fontsize=12, fontweight='bold', va='top', ha='right')

axs[0].set_xlabel('Latitude (°N)')
axs[1].set_xlabel('Latitude (°N)')
axs[2].set_xlabel('Latitude (°N)')

fig.savefig('output/pico_frac.png', dpi=300, bbox_inches='tight')