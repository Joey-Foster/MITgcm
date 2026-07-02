#!/usr/bin/env python

import xarray as xr
import matplotlib.pyplot as plt
import io
import imageio.v3 as iio

PATH_TO_NC = 'run/state_global.nc'

ds = xr.open_dataset(PATH_TO_NC, chunks={})

theta = ds['Temp'].sel(X=slice(0,4000))
time = ds['T']

frames = []
for i, t in enumerate(time.values):
    plt.figure()
    theta.isel(T=i).plot(
        cbar_kwargs={'label':r'$\theta$ [degC]'},
        cmap = 'jet',
        vmin = -0.075,
        vmax = 0.005
        )
    plt.title(f'Potential temperature at t={int(t)}s')
    plt.xlabel('X [km]')
    plt.ylabel('Depth [m]')
    
    buf = io.BytesIO()
    plt.savefig(buf, format='png', bbox_inches='tight')
    buf.seek(0)
    
    frames.append(iio.imread(buf))
    plt.close()
    
iio.imwrite('animation.gif', frames, fps=30, loop=0)