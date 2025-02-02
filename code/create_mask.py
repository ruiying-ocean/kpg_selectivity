import numpy as np
import matplotlib.pyplot as plt
from cgeniepy.model import GenieModel
import xarray as xr

# Load the model and land-sea mask
model = GenieModel("/Users/yingrui/science/kpg_ecosystem/model/muffin.u067bc.PO4.EXP3/")
land_sea_mask = model.grid_mask().data 

## the last row to be masked
land_sea_mask[35, :] = np.nan

# Create a mask initialized to False
mask = np.zeros_like(land_sea_mask, dtype=bool)

def on_click(event):
    """Callback function for mouse clicks."""
    if event.inaxes is not None:  # Ensure click is inside plot
        x, y = int(event.xdata), int(event.ydata)  # Get integer indices
        mask[y, x] = not mask[y, x]  # Toggle mask value (True/False)
        update_display()

def update_display():
    """Updates the displayed image with the applied mask."""
    masked_array = np.where(mask, np.nan, land_sea_mask)  # Apply mask
    
    ax.clear()
    ax.imshow(masked_array, cmap="viridis", origin="lower", interpolation="nearest")
    ax.set_title("Click to mask/unmask pixels")
    fig.canvas.draw()

def save_masked_array():
    """Saves the final masked array to a file."""
    masked_array = np.where(mask, np.nan, land_sea_mask)  # Apply mask

    ## add coordinate and save to xarray
    ls_mask = xr.DataArray(masked_array, dims=("lat", "lon"), 
                           coords={"lat": land_sea_mask.lat, "lon": land_sea_mask.lon})
    ls_mask.to_netcdf("masked_array.nc")

    print("Masked array saved to 'masked_array.npy'")

# Plot initial image
fig, ax = plt.subplots()
ax.imshow(land_sea_mask, cmap="viridis", origin="lower")
ax.set_title("Click to mask/unmask pixels")

# Connect the click event
fig.canvas.mpl_connect("button_press_event", on_click)

plt.show()  # Interactive mode

# Save the final masked array after closing the plot
save_masked_array()