#!/usr/bin/env python

import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
import matplotlib.colors as colors
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
    
def CheckEndTimes(datasets):
    times = {}
    for i, ds in enumerate(datasets):
        times[i] = ds['T'].values
    if len(set( [t[-1] for t in times.values()] )) != 1:
        for t in times.values():
            print(t[-1])
        raise Exception('End time conflict')
    else:
        return times
        
def comparison_plot(times, values, ylabel, title, save):
    # times and values are dictionaries of size (3, len(ds['T'].values))
    # ylabel, title, and save are strings
    # (cba to do proper type hinting)
    labels = ['truth', 'off', 'on']
    plt.figure()
    for i, time in times.items():
        val = values[i]
        plt.plot(time, val, label=f'{labels[i]}')
    plt.xlabel('Time [s]')
    plt.legend()
    plt.ylabel(ylabel)
    plt.title(title)
    plt.savefig(f'{save}.pdf', bbox_inches='tight')
    
###############################################################################

def compute_temperature_flux(ds, X_pos, time_idx):
    u = ds['U'].isel(T=time_idx).sel(Xp1=X_pos, method='nearest')
    theta = ds['Temp'].isel(T=time_idx).sel(X=X_pos, method='nearest')
    dz = ds['Z'][1] - ds['Z'][0]
    
    differential_theta_flux = u * theta * dz
    return differential_theta_flux.sum(dim='Z').values[0]

def plot_tempertature_flux(datasets, times, X_pos):
    fluxes = {i: [compute_temperature_flux(ds, X_pos, j) 
                  for j in range(len(times[i]))
              ] for i, ds in enumerate(datasets)}
    comparison_plot(times, fluxes, 
                    r'Temperature flux [degC m$^2$ s$^{-1}$]', 
                    f'Temperature flux through X = {X_pos}', 
                    f'Temperature_flux_comparison_x={X_pos}')


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

def plot_heat_content(datasets, times, X_pos):
    heat = {i: [eastward_heat_content(ds, X_pos, j)
                for j in tqdm(range(len(times[i][::10])), # ::10 as don't need high temporal resolution
                              desc=f'Computing heat content for dataset {i+1}/{len(datasets)}') 
            ] for i, ds in enumerate(datasets)}
    comparison_plot(times, heat, 
                    r'Heat content [J s$^{-1}$]', 
                    f'Heat content east of X = {X_pos}', 
                    f'eastward_heat_comparison_x={X_pos}')    

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

def temperature_flux_moving_tavg(datasets, times, X_pos, window=3):
    labels=['truth', 'off', 'on']
    fig, ax = plt.subplots()

    for i, ds in enumerate(datasets):
        fluxes = [compute_temperature_flux(ds, X_pos, j) for j in range(len(times[i]))]
        averaged = np.lib.stride_tricks.sliding_window_view(fluxes, window).mean(axis=1)
        if window % 2 == 0:
            time_windowed = times[i][window//2-1:-window//2] # convention to lose 1 extra point 
                                                         # on the left for the even window
        else:
            time_windowed = times[i][window//2:-(window//2)]
        
        plt.plot(time_windowed, averaged, label=labels[i])
        plt.xlabel('Time [s]')
        plt.ylabel(r'Temperature flux [degC m$^2$ s$^{-1}$]')
        plt.title(f'Time-averaged temperature flux through X = {X_pos}')
        # fig.text(0.15, 0.815, f'window = {window * int(times[i][1] - times[i][0])}s', 
        #          bbox=dict(boxstyle="round,pad=0.3", fc="white", alpha=0.9))
        fig.text(0.15, 0.815, f'window = {window}*{{dt for each dataset}}', 
                bbox=dict(boxstyle="round,pad=0.3", fc="white", alpha=0.9))#
    plt.legend(loc='lower right')
    plt.savefig(f'time-averaged-temperature_flux_comparison_x={X_pos}.pdf', bbox_inches='tight')
    
def coarsen_data(ds, linear_sf):
    array = ds.values
    nz, ny, nx = np.shape(array)
    coarsened = array.reshape(nz//linear_sf, linear_sf, nx//linear_sf, linear_sf).mean(axis=(1,3))
    return coarsened

def plot_flux_div_diff(ds_coarse, ds_hr, time_idx):
    div_c = temperature_flux_divergence(ds_coarse, time_idx)
    
    div_hr = temperature_flux_divergence(ds_hr, time_idx)
    div_hr_c_values = coarsen_data(div_hr, linear_sf=2)
    nz, nx = np.shape(div_hr_c_values)
    div_hr_c_values = div_hr_c_values.reshape(nz, 1, nx) # force Y slice for dimension compatibility
    div_hr_c = xr.DataArray(
        data=div_hr_c_values,
        coords=div_c.coords,
        dims=div_c.dims
        )

    diff = div_hr_c - div_c
    plt.figure()
    diff.plot(
        cbar_kwargs={'label':r'$\log_{10}\left(\nabla\cdot(\mathbf{u}\theta_{hr})-\nabla\cdot(\mathbf{u}\theta_{c})\right)$'},
        cmap = 'seismic',
        # vmin = diff.min().values,
        # vmax = diff.max().values,
        norm=colors.SymLogNorm(linthresh=5e-6)
        )
                               
    plt.title("SymLog difference in temperature flux divergence\n"
              f"between highres and coarse runs, at t={int(diff['T'].values)}s")
    plt.xlabel('X [m]')
    plt.ylabel('Depth [m]')
    plt.savefig(f"flux_div_diff_t={int(diff['T'].values)}", bbox_inches='tight')
    
def temperature_histogram(ds, time_idx):
    # more work to do here to plot and extract useful information...
    
    time = ds['T'].values
    theta = ds['Temp'].isel(T=time_idx).values.ravel()
    plt.figure()
    plt.hist(theta, bins=400)
    tmin, tmax = [-0.01, 0.01]
    plt.xlim([tmin, tmax])
    plt.xlabel('Potential temperature [degC]')
    plt.title(f'Temperature classes per grid cell at t={int(time[time_idx])}')
    
    zoomed_theta = theta[theta >= tmin]
    mean = np.mean(zoomed_theta)
    std = np.std(zoomed_theta)
    print(f'{mean=}, {std=}')
    # plt.savefig(f'temperature_histogram_t={int(time[time_idx])}.pdf', bbox_inches='tight')

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser()
    parser.add_argument('--truth', help="Path to highres multiscale bathymetry state_global.nc file", 
                        required=True, metavar='path/to/file')
    parser.add_argument('--off', help="Path to coarse smooth bathymetry state_global.nc file "
                        "and without my custom package", metavar='path/to/file')
    parser.add_argument('--on', help="Path to coarse smooth bathymetry state_global.nc file "
                        "with my custom package", metavar='path/to/file')
    
    parser.add_argument('-f', '--flux', help='Save temperature flux figure', action='store_true')
    parser.add_argument('-hc', '--heat', help='Save heat content figure', action='store_true')
    parser.add_argument('--hist', help='Save temperature histogram at final time', action='store_true')
    parser.add_argument('-d', '--div', help='Save flux divergence at final time', action='store_true')
    parser.add_argument('-dl', "--div-loc", help="Save localised flux divergence at final time "
                        "by providing 4 floats", nargs=4, type=float, 
                        metavar=("X_start", "X_end", "Z_start", "Z_end"))
    parser.add_argument('-taf', '--tavg-flux', help='Save time-averaged tempertaure flux '
                        'by providing the number of timesteps for the averaging window',
                        type=int, metavar='Window size')
    args=parser.parse_args()

    ds_truth = xr.open_dataset(args.truth, chunks={})
    ds_off = xr.open_dataset(args.off, chunks={})
    ds_on = xr.open_dataset(args.on, chunks={})
    
    datasets = [ds_truth, ds_off, ds_on]
    times = CheckEndTimes(datasets)
    
    if args.flux:
        plot_tempertature_flux(datasets, times, 1000)
    # if args.heat:
    #     plot_heat_content(datasets, times, 1000)
    # if args.div:
    #     plot_flux_divergence(ds, -1, savefig=True)
    # if args.div_loc is not None:
    #     ranges = tuple(args.div_loc)
    #     plot_flux_divergence(ds, -1, X_range=ranges[:2], Z_range=ranges[2:], savefig=True)
    if args.tavg_flux:
        temperature_flux_moving_tavg(datasets, times, 1000, window=args.tavg_flux)
    # if args.d2:
    #     ds2 = xr.open_dataset(args.d2, chunks={})
    #     plot_flux_div_diff(ds, ds2, -1)
    # if args.hist:
    #     temperature_histogram(ds, -1)
        

    # for i in range(len(ds['T'].values)):
    #     basic_plot(ds, i)
        # plot_flux_divergence(ds, i)