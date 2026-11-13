#!/usr/bin/env python

import xarray as xr
import matplotlib.pyplot as plt
import io
import imageio.v3 as iio
from tqdm import tqdm
import argparse
from quantitative_analysis import compute_temperature_flux

def create_qual_quant_fig(t_idx, t, theta, fluxes):
    
    fig, ax = plt.subplots(1,2,figsize=(15,5))
    theta.isel(T=t_idx).plot(
        ax=ax[0],
        cbar_kwargs={'label':r'$\theta$ [degC]'},
        cmap = 'jet',
        vmin = theta.isel(T=-1).min().values,
        vmax = theta.isel(T=-1).max().values
        )
    ax[0].plot([x_pos, x_pos], [ds['Z'].values[0], ds['Z'].values[-1]],
               lw=0.9, alpha=0.5, c='k')
    ax[0].set_title(f'Potential temperature at t={int(t)}s')
    ax[0].set_xlabel('X [m]')
    ax[0].set_ylabel('Depth [m]')
    
    ax[1].plot(times[:t_idx], fluxes[:t_idx])
    ax[1].set_xlim(-0.05*times[-1], times[-1]*1.05)
    flux_diff = max(fluxes) - min(fluxes)
    ax[1].set_ylim(min(fluxes)-0.05*flux_diff, max(fluxes)+0.05*flux_diff)
    ax[1].set_xlabel('Time [s]')
    ax[1].set_ylabel(r'Temperature flux [degC m$^2$ s$^{-1}$]')
    ax[1].set_title(f'Temperature flux through X = {x_pos}')
    
    return fig

    
def export_animation(time_iterable, create_fig):
    
    frames = []
    for i, t in enumerate(tqdm(time_iterable, desc='Generating GIF frames')):

        fig = create_fig(i, t, theta, fluxes)
        buf = io.BytesIO()
        fig.savefig(buf, format='png', bbox_inches='tight')
        buf.seek(0)
        
        frames.append(iio.imread(buf))
        # plt.show()
        plt.close()
        
    iio.imwrite('animation.gif', frames, fps=20, loop=0)


if __name__ == '__main__':
    
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', help="Path to .nc file", required=True)
    args=parser.parse_args()

    ds = xr.open_dataset(args.d, chunks={})

    theta = ds['Temp'].sel(X=slice(0,3000))
    times = ds['T'].values
        
    x_pos = 1000
    fluxes = [compute_temperature_flux(ds, x_pos, i) for i in range(len(times))]
    
    export_animation(times, create_qual_quant_fig)