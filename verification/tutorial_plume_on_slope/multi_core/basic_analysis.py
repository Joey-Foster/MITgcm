#!/usr/bin/env python

import xarray as xr
import matplotlib.pyplot as plt
import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-n', '--off', help='file path to state_global.nc without ' 
                    'subgrid term', required=True)
parser.add_argument('-y', '--on', help='file path to state_global.nc with '
                    'subgrid term', required=True)
args=parser.parse_args()

ds_off = xr.open_dataset(args.off, chunks={})
ds_on = xr.open_dataset(args.on, chunks={})

theta_off = ds_off['Temp'].sel(X=slice(0,3000))
theta_on = ds_on['Temp'].sel(X=slice(0,3000))

time = ds_off['T'].values
if time[-1] != ds_on['T'].values[-1]:
    print('Warning: Datasets do not share the same end time')

plotting_customisation = {'cmap': 'jet',
                          'vmin': -0.08, # Hardcoded to match tutorial figure colorbar
                          'vmax': 0.005, #
                          'add_colorbar': False
                          }
fig, ax = plt.subplots(1,2, constrained_layout=True, sharey=True)
im = theta_off.sel(T=time[-1], method='nearest').plot(ax=ax[0], **plotting_customisation)
ax[0].set_xlabel('X [m]')
ax[0].set_ylabel('Depth [m]')
ax[0].set_title('useBAHTY_HOMOG=.FALSE.')

theta_on.isel(T=-1).plot(ax=ax[1], **plotting_customisation)
ax[1].set_xlabel('X [m]')
ax[1].set_ylabel('')
ax[1].set_title('useBATHY_HOMOG=.TRUE.')
    
cbar = fig.colorbar(im, ax=ax, orientation="horizontal")
cbar.set_label(r'$\theta$ [degC]')
plt.suptitle(rf'Potential tempertaure at $t={{ {int(time[-1])} }}$s')
plt.savefig('comparison.pdf', bbox_inches='tight')

