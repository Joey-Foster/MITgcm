#!/usr/bin/env python

import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
import argparse
from tqdm import tqdm

def basic_plot(ds, time_idx):
    "For debugging - does not save output"
    
    theta=ds['Temp']
    plt.figure()
    theta.isel(T=time_idx).plot(
        cbar_kwargs={'label':r'$\theta$ [degC]'},
        cmap = 'jet',
        vmin = theta.isel(T=time_idx).min().values,
        vmax = theta.isel(T=time_idx).max().values
        )   
    plt.title(f"Potential temperature at t={int(ds['T'].values[time_idx])}s")
    plt.xlabel('X [m]')
    plt.ylabel('Depth [m]')
    plt.show()

def compute_temperature_flux(ds, X_pos, time_idx):
    u = ds['U'].isel(T=time_idx).sel(Xp1=X_pos, method='nearest')
    theta = ds['Temp'].isel(T=time_idx).sel(X=X_pos, method='nearest')
    dz = ds['Z'][1] - ds['Z'][0]
    
    differential_theta_flux = u * theta * dz
    return differential_theta_flux.sum(dim='Z').values[0]

def plot_tempertature_flux(ds, X_pos):
    time = ds['T'].values
    fluxes = [compute_temperature_flux(ds, X_pos, i) for i in range(len(time))]
    plt.figure()
    plt.plot(time, fluxes)
    plt.xlabel('Time [s]')
    plt.ylabel(r'Temperature flux [degC m$^2$ s$^{-1}$]')
    plt.title(f'Temperature flux through X={X_pos}')
    plt.savefig(f'Temperature_flux_x={X_pos}.pdf', bbox_inches='tight')


def closest_index(arr, x):
    "ChatGPT-generated"
    idx = np.searchsorted(arr, x)

    if idx == 0:
        return 0
    if idx == len(arr):
        return len(arr) - 1

    if abs(arr[idx - 1] - x) <= abs(arr[idx] - x):
        return idx - 1
    return idx

def eastward_heat_content(ds, X_pos, time_idx):
    rho0 = 999.8 # kg/m^3
    Cp = 4000 # J/(kg degC)
    Y = ds['Y'].values[0] # dy = 0 so dA = Y*dz
    starting_X_idx = closest_index(ds['X'].values, X_pos)
    total_eastward_heat = 0
    for x in ds['X'].values[starting_X_idx:]:
        total_eastward_heat += rho0 * Cp * Y * compute_temperature_flux(ds, x, time_idx)

    return total_eastward_heat

def plot_heat_content(ds, X_pos):
    time = ds['T'].values
    heat = [eastward_heat_content(ds, X_pos, i) for i in tqdm(range(len(time)), desc='Computing heat content')]
    plt.figure()
    plt.plot(time, heat)
    plt.xlabel('Time [s]')
    plt.ylabel(r'Heat content [J s$^{-1}$]')
    plt.title(f'Heat content east of X={X_pos}')
    plt.savefig('eastward_heat_content.pdf', bbox_inches='tight')
    
def temperature_flux_divergence(ds, time_idx, X_range=(None, None), Z_range=(None, None)):
    
    theta = ds['Temp'].isel(T=time_idx)
    u = ds['U'].isel(T=time_idx).interp(Xp1=ds['Temp'].X)
    w = ds['W'].isel(T=time_idx).interp(Zl=ds['Temp'].Z)
        
    theta, u, w = [ds.sel(X=slice(*X_range), Z=slice(*Z_range)) for ds in [theta, u, w]] 
    
    flux_density_x = u*theta
    flux_density_z = w*theta

    flux_divergence = flux_density_x.differentiate('X') + flux_density_z.differentiate('Z')
    return flux_divergence

def plot_flux_divergence(ds, time_idx, X_range=(None, None), Z_range=(None, None), savefig=False):
    plt.figure()
    div = temperature_flux_divergence(ds, time_idx, X_range, Z_range)
    logged = np.log10(np.abs(div) + 1e-10)
    logged.plot(
        cbar_kwargs={'label':r'$\log_{10}\left|\nabla \cdot (\mathbf{u}\theta)\right|$'},
        cmap = 'viridis',
        vmin = logged.min().values,
        vmax = logged.max().values
        )
    plt.title(f"Log divergence of tempertature flux at t = {int(ds['T'].values[time_idx])}")
    plt.xlabel('X [m]')
    plt.ylabel('Depth [m]')
    if savefig:
        plt.savefig(f"flux_divergence_t={ds['T'].values[time_idx]}.pdf", bbox_inches='tight')

def temperature_flux_moving_tavg(ds, X_pos, window=3):
    time = ds['T'].values
    fluxes = [compute_temperature_flux(ds, X_pos, i) for i in range(len(time))]
    averaged = np.lib.stride_tricks.sliding_window_view(fluxes, window).mean(axis=1)
    if window % 2 == 0:
        time_windowed = time[window//2-1:-window//2] # convention to lose 1 extra point 
                                                     # on the left for the even window
    else:
        time_windowed = time[window//2:-(window//2)]
    fig, ax = plt.subplots()
    plt.plot(time_windowed, averaged)
    plt.xlabel('Time [s]')
    plt.ylabel(r'Temperature flux [degC m$^2$ s$^{-1}$]')
    plt.title(f'Time-averaged temperature flux through X={X_pos}')
    fig.text(0.15, 0.815, f'window = {window * int(time[1] - time[0])}s', 
             bbox=dict(boxstyle="round,pad=0.3", fc="white", alpha=0.9))
    plt.savefig(f'time-averaged-temperature_flux_x={X_pos}.pdf', bbox_inches='tight')
    
def coarsen_data(ds, linear_sf):
    array = ds.values
    nz, ny, nx = np.shape(array)
    coarsened = array.reshape(nz//linear_sf, linear_sf, nx//linear_sf, linear_sf).mean(axis=(1,3))
    return coarsened

def plot_flux_div_diff(ds_coarse, ds_hr, time_idx):
    div_c = temperature_flux_divergence(ds_coarse, time_idx)
    
    div_hr = temperature_flux_divergence(ds_hr, time_idx)
    div_hr_c_values = coarsen_data(div_hr, linear_sf=4)
    nz, nx = np.shape(div_hr_c_values)
    div_hr_c_values = div_hr_c_values.reshape(nz, 1, nx) # force Y slice for dimension compatibility
    div_hr_c = xr.DataArray(
        data=div_hr_c_values,
        coords=div_c.coords,
        dims=div_c.dims
        )

    diff = abs(div_c - div_hr_c)
    logged_diff = np.log10(diff + 1e-7)
    plt.figure()
    logged_diff.plot(
        cbar_kwargs={'label':r'$\log_{10}\left|\nabla(\mathbf{u}\theta_1)-\nabla(\mathbf{u}\theta_2)\right|$'},
        cmap = 'viridis',
        vmin = logged_diff.min().values,
        vmax = logged_diff.max().values
        )   
    plt.title("Log absolute difference in temperature flux divergence\n"
              f"between coarse and highres runs, at t={int(diff['T'].values)}s")
    plt.xlabel('X [m]')
    plt.ylabel('Depth [m]')
    plt.savefig(f"flux_div_diff_t={int(diff['T'].values)}", bbox_inches='tight')
        # do args

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', help="Path to .nc file", required=True, metavar='path/to/file')
    parser.add_argument('-d2', help="Saves flux divergence difference at final time "
                        "by providing path to higher resolution .nc file", metavar='path/to/file')
    parser.add_argument('-f', '--flux', help='Save temperature flux figure', action='store_true')
    parser.add_argument('-hc', '--heat', help='Save heat content figure', action='store_true')
    parser.add_argument('--div', help='Save flux divergence at final time', action='store_true')
    parser.add_argument("--div-loc", help="Save localised flux divergence at final time "
                        "by providing 4 floats", nargs=4, type=float, 
                        metavar=("X_start", "X_end", "Z_start", "Z_end"))
    parser.add_argument('-t', '--tavg', help='Save time-averaged tempertaure flux '
                        'by providing the number of timesteps for the averaging window',
                        type=int, metavar='Window size')
    args=parser.parse_args()

    ds = xr.open_dataset(args.d, chunks={})
    
    if args.flux:
        plot_tempertature_flux(ds, 500)
    if args.heat:
        plot_heat_content(ds, 500)
    if args.div:
        plot_flux_divergence(ds, -1, savefig=True)
    if args.div_loc is not None:
        ranges = tuple(args.div_loc)
        plot_flux_divergence(ds, -1, X_range=ranges[:2], Z_range=ranges[2:], savefig=True)
    if args.tavg:
        temperature_flux_moving_tavg(ds, 500, window=args.tavg)
    if args.d2:
        ds2 = xr.open_dataset(args.d2, chunks={})
        plot_flux_div_diff(ds, ds2, -1)
        

    # for i in range(len(ds['T'].values)):
    #     basic_plot(ds, i)
        # plot_flux_divergence(ds, i)