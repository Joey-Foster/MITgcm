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
    
def temperature_flux_divergence(ds, time_idx):
    
    theta = ds['Temp'].isel(T=time_idx)
    u = ds['U'].isel(T=time_idx).interp(Xp1=ds['Temp'].X)
    w = ds['W'].isel(T=time_idx).interp(Zl=ds['Temp'].Z)
    
    flux_density_x = u*theta
    flux_density_z = w*theta

    flux_divergence = flux_density_x.differentiate('X') + flux_density_z.differentiate('Z')
    return flux_divergence

def plot_flux_divergence(ds, time_idx, savefig=False):
    plt.figure()
    div = temperature_flux_divergence(ds, time_idx)
    logged = np.log10(np.abs(div) + 1e-16)
    logged.plot(
        cbar_kwargs={'label':r'$\log_{10}\left|\nabla \cdot (\mathbf{u}\theta)\right|$'},
        cmap = 'viridis',
        vmin = logged.min().values,
        vmax = logged.max().values
        )
    plt.title(f"Log of the divergence of tempertature flux at t = {ds['T'].values[time_idx]}")
    plt.xlabel('X [m]')
    plt.ylabel('Depth [m]')
    if savefig:
        plt.savefig(f"flux_divergence_t={ds['T'].values[time_idx]}.pdf", bbox_inches='tight')


if __name__ == "__main__":
    
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', help="Path to .nc file", required=True)
    parser.add_argument('-f', '--flux', help='Save temperature flux figure', action='store_true')
    parser.add_argument('-hc', '--heat', help='Save heat content figure', action='store_true')
    parser.add_argument('--div', help='Save flux divergence at final time', action='store_true')
    args=parser.parse_args()

    ds = xr.open_dataset(args.d, chunks={})
    
    if args.flux:
        plot_tempertature_flux(ds, 500)
    if args.heat:
        plot_heat_content(ds, 500)
    if args.div:
        plot_flux_divergence(ds, -1, savefig=True)
    
    # for i in range(len(ds['T'].values)):
        # basic_plot(ds, i)
        # plot_flux_divergence(ds, i)