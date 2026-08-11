#!/usr/bin/env python

import xarray as xr
import matplotlib.pyplot as plt
import io
import imageio.v3 as iio
from tqdm import tqdm
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-d', help="Path to .nc file", default="run/state_global.nc")
args=parser.parse_args()

ds = xr.open_dataset(args.d, chunks={})

theta = ds['Temp'].sel(X=slice(0,3000))
time = ds['T']

frames = []
for i, t in enumerate(tqdm(time.values, desc='Generating GIF frames')):
    plt.figure()
    theta.isel(T=i).plot(
        cbar_kwargs={'label':r'$\theta$ [degC]'},
        cmap = 'jet',
        vmin = theta.isel(T=-1).min().values,
        vmax = theta.isel(T=-1).max().values
        )   
    plt.title(f'Potential temperature at t={int(t)}s')
    plt.xlabel('X [m]')
    plt.ylabel('Depth [m]')
    
    buf = io.BytesIO()
    plt.savefig(buf, format='png', bbox_inches='tight')
    buf.seek(0)
    
    frames.append(iio.imread(buf))
#    plt.show()
    plt.close()
    
iio.imwrite('animation.gif', frames, fps=20, loop=0)
