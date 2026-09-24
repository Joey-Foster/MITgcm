#!/usr/bin/env python

import xarray as xr
import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-t', '--truth', help='file path to state_global.nc with high res ' 
                    'multiscale bathymetry, represneting the "truth"', required=True)
parser.add_argument('--off', help='file path to state_global.nc with smooth coarse '
                    'bathymetry and WITHOUT my custom package', required=True)
parser.add_argument('--on', help='file path to state_global.nc with smooth coarse '
                    'bathymetry and WITH my custom package', required=True)
args=parser.parse_args()

datasets = {}
thetas = {}
for flag, path in vars(args).items():
    if path is not None:
        datasets[flag] = xr.open_dataset(path, chunks={})
        thetas[flag] = datasets[flag]['Temp'].sel(X=slice(0,3000))

if len(set([datasets[flag]['T'].values[-1] for flag, path in vars(args).items() if path is not None])) != 1:
    print('Warning: Datasets do not share a common end time.\n'
          'Defaulting to "highres" dataset time axis.')
time = datasets['truth']['T'].values

vmin = thetas['truth'].isel(T=-1).min().values
vmax = thetas['truth'].isel(T=-1).max().values

plotting_customisation = {'cmap': 'jet',
                          #'vmin': vmin, 
                           'vmin': -0.08,
                          #'vmax': vmax,
                           'vmax': 0.005,
                          'add_colorbar': False
                          }

fig, ax = plt.subplots(1, 3, constrained_layout=True, sharey=True, figsize=(10,5))
im = thetas['truth'].isel(T=-1).plot(ax=ax[0], **plotting_customisation)
ax[0].set_xlabel('X [m]')
ax[0].set_ylabel('Depth [m]')
ax[0].set_title('Multiscale bathymetry\n("truth")')

thetas['off'].isel(T=-1).plot(ax=ax[1], **plotting_customisation)
ax[1].set_xlabel('X [m]')
ax[1].set_ylabel('')
ax[1].set_title('Smooth bathymetry\n (homog OFF)')

thetas['on'].isel(T=-1).plot(ax=ax[2], **plotting_customisation)
ax[2].set_xlabel('X [m]')
ax[2].set_ylabel('')
ax[2].set_title('Smooth bathymetry\n (homog ON)')
    
cbar = fig.colorbar(im, ax=ax, orientation="horizontal")
cbar.set_label(r'$\theta$ [degC]')
plt.suptitle(rf'Potential tempertaure at $t={{ {int(time[-1])} }}$s')

plt.savefig('homogenisation_comparison.pdf', bbox_inches='tight')
