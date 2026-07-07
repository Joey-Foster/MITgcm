#!/usr/bin/env python

import xarray as xr
import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-s', '--smooth', help='file path to state_global.nc with smooth ' 
                    'bathymetry and which does not use wall functions', required=True)
parser.add_argument('-swf', '--smooth+wallfuncs', help='file path to state_global.nc with smooth ' 
                    'bathymetry and which uses wall functions', required=True)
parser.add_argument('-w', '--wiggly', help='file path to state_global.nc with '
                    'multiscale bathymetry and which does not use wall functions',
                    required=True)
parser.add_argument('-wwf', '--wiggly+wallfuncs', help='file path to state_global.nc with '
                    'multiscale bathymetry and which uses wall functions', required=True)
args=parser.parse_args()

datasets = {}
thetas = {}
for flag, path in vars(args).items():
    datasets[flag] = xr.open_dataset(path, chunks={})
    thetas[flag] = datasets[flag]['Temp'].sel(X=slice(0,3000))

if len(set([datasets[flag]['T'].values[-1] for flag in vars(args).keys()])) != 1:
    print('Warning: Datasets do not share a common end time.\n'
          'Defaulting to "smooth" dataset time axis.')
time = datasets['smooth']['T'].values

plotting_customisation = {'cmap': 'jet',
                          'vmin': -0.08, # Hardcoded to match tutorial figure colorbar
                          'vmax': 0.005, # 
                          'add_colorbar': False
                          }
fig, ax = plt.subplots(2,2, constrained_layout=True, sharex=True, sharey=True, figsize=(8,6))
im = thetas['smooth'].isel(T=-1).plot(ax=ax[0,0], **plotting_customisation)
ax[0,0].set_xlabel('')
ax[0,0].set_ylabel('Depth [m]')
ax[0,0].set_title('Smooth bathymetry')

thetas['wiggly'].isel(T=-1).plot(ax=ax[0,1], **plotting_customisation)
ax[0,1].set_xlabel('')
ax[0,1].set_ylabel('')
ax[0,1].set_title('Multiscale bathymetry')
ax[0,1].text(1.02, 0.5, "No wall functions", 
             transform=ax[0,1].transAxes, rotation=-90, va="center", ha="left", fontsize=12)

thetas['smooth+wallfuncs'].isel(T=-1).plot(ax=ax[1,0], **plotting_customisation)
ax[1,0].set_xlabel('X [m]')
ax[1,0].set_ylabel('Depth [m]')
ax[1,0].set_title('')

thetas['wiggly+wallfuncs'].isel(T=-1).plot(ax=ax[1,1], **plotting_customisation)
ax[1,1].set_xlabel('X [m]')
ax[1,1].set_ylabel('')
ax[1,1].set_title('')
ax[1,1].text(1.02, 0.5, "Wall functions", 
             transform=ax[1,1].transAxes, rotation=-90, va="center", ha="left", fontsize=12)
    
cbar = fig.colorbar(im, ax=ax, orientation="horizontal")
cbar.set_label(r'$\theta$ [degC]')
plt.suptitle(rf'Potential tempertaure at $t={{ {int(time[-1])} }}$s')
plt.savefig('bathymetry_comparison_2x2.pdf', bbox_inches='tight')