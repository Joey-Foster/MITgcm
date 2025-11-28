"""
Generates input data files for MITgcm tutorial_plume_on_slope
Converted from MATLAB gendata.m
"""

import numpy as np

# Precision and byte order settings - use proper NumPy dtype
prec = np.dtype('>f8')  # big-endian 64-bit float (equivalent to MATLAB 'real*8' with 'b')

# Dimensions of grid
nx = 1280
ny = 1
nz = 240

# Nominal depth of model (meters)
H = 200.0

# Size of domain
Lx = 6.40e3

# Horizontal resolution (m)
# Variable resolution
res1 = 2 * Lx / (3 * nx)
L1 = Lx / 2
L2 = Lx - L1
n2 = nx - (L1 / res1)
res2 = L2 / n2
A = res2 - res1
iswitch1 = L1 / res1
width = 40

dx = np.zeros(nx, dtype=np.float64)
for i in range(nx):
    dx[i] = res1 + 0.5 * A * (np.tanh((i + 1 - iswitch1) / width) + 1)
    # dx[i] = Lx / nx  # uniform resolution alternative

dy = Lx / nx

# Flux
Qo = 200

# Stratification
gravity = 9.81
talpha = 2.0e-4
N2 = 0.0
Tz =  N2 / (gravity * talpha)


dz = H / nz
print(f'delZ = {nz} * {dz:7.6g}')

# Calculate x coordinates
x = np.zeros(nx, dtype=np.float64)
x[0] = dx[0]
for i in range(1, nx):
    x[i] = x[i-1] + dx[i]

z = np.arange(-dz/2, -H-dz/2, -dz)

# Tanh function for cooling
xswitch = 2.50e3 + Lx / 2.0
qwidth = 0.1e3
Q = np.zeros((nx, ny), dtype=np.float64)
for i in range(nx):
    Q[i, :] = Q[i, :] + Qo * 0.5 * (np.tanh((Lx - x[i] - xswitch) / qwidth) + 1)
    # Q[i, :] = Q[i, :] + Qo * 0.5 * (np.tanh((x[i] - xswitch) / qwidth) + 1)  # alternative

# Write Qnet forcing file
with open('Qnet.forcing', 'wb') as fid:
    Q.astype(prec).tofile(fid)

# Temperature profile
Tref = Tz * z - np.mean(Tz * z)
print('Tref =', ', '.join([f'{val:8.6g}' for val in Tref]))

t = 0.01 * np.random.rand(nx, ny, nz)
for k in range(nz):
    t[:, :, k] = t[:, :, k] + Tref[k]

# Write temperature initialization file
with open('T.init', 'wb') as fid:
    t.flatten(order='F').astype(prec).tofile(fid)

# Sloping channel
# tanh function for slope
slope = 0.15
offset = 1.5e3 + Lx / 2.0
dmax = -40.0
h1 = dmax
h2 = -H
hdiff = h1 - h2
xwidth = hdiff / (2.0 * slope)

d = np.zeros((nx, ny), dtype=np.float64)
for i in range(nx):
    for j in range(ny):
        # d[i, j] = hdiff/2 * (np.exp((x[i]-offset)/xwidth) - np.exp(-(x[i]-offset)/xwidth)) / (np.exp((x[i]-offset)/xwidth) + np.exp(-(x[i]-offset)/xwidth)) + hdiff/2 - H
        d[i, j] = hdiff / 2 * (np.tanh((Lx - x[i] - offset) / xwidth) + 1) - H

d[0, :] = 0.0

# Write topography file
with open('topog.slope', 'wb') as fid:
    d.astype(prec).tofile(fid)

# Plot the bathymetry
# import matplotlib.pyplot as plt
# plt.figure()
# plt.plot(x, d[:, 0])
# plt.xlabel('x (m)')
# plt.ylabel('Depth (m)')
# plt.title('Bathymetry Profile')
# plt.grid(True)
# plt.show()

# Write dx spacing file
with open('dx.bin', 'wb') as fid:
    dx.astype(prec).tofile(fid)

print("Data generation complete!")
print(f"Grid dimensions: nx={nx}, ny={ny}, nz={nz}")
print(f"dx range: {np.min(dx):.6f} to {np.max(dx):.6f} m")
print(f"dz = {dz:.6f} m")
print(f"Temperature range: {np.min(t):.6f} to {np.max(t):.6f}")
print(f"Bathymetry range: {np.min(d):.6f} to {np.max(d):.6f} m")
print(f"Q forcing range: {np.min(Q):.6f} to {np.max(Q):.6f}")