#!/usr/bin/env python

import xarray as xr
import matplotlib.pyplot as plt
import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-s', '--smooth', help='file path to state_global.nc with smooth ' 
                    'bathymetry', required=True)
parser.add_argument('-w', '--wiggly', help='file path to state_global.nc with '
                    'multiscale bathymetry', required=True)
args=parser.parse_args()

ds_smooth = xr.open_dataset(args.smooth, chunks={})
ds_wiggly = xr.open_dataset(args.wiggly, chunks={})

theta_smooth = ds_smooth['Temp'].sel(X=slice(0,3000))
theta_wiggly = ds_wiggly['Temp'].sel(X=slice(0,3000))

time = ds_smooth['T'].values
if time[-1] != ds_wiggly['T'].values[-1]:
    print('Warning: Datasets do not share the same end time')

plotting_customisation = {'cmap': 'jet',
                          'vmin': -0.08, # Hardcoded to match tutorial figure colorbar
                          'vmax': 0.005, #
                          'add_colorbar': False
                          }
fig, ax = plt.subplots(1,2, constrained_layout=True, sharey=True)
im = theta_smooth.sel(T=time[-1], method='nearest').plot(ax=ax[0], **plotting_customisation)
ax[0].set_xlabel('X [m]')
ax[0].set_ylabel('Depth [m]')
ax[0].set_title('Low res')

theta_wiggly.isel(T=-1).plot(ax=ax[1], **plotting_customisation)
ax[1].set_xlabel('X [m]')
ax[1].set_ylabel('')
ax[1].set_title('High res')
    
cbar = fig.colorbar(im, ax=ax, orientation="horizontal")
cbar.set_label(r'$\theta$ [degC]')
plt.suptitle(rf'Potential tempertaure at $t={{ {int(time[-1])} }}$s')
plt.savefig('bathymetry_comparison.pdf', bbox_inches='tight')

