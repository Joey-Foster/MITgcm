"""
Generates input data files for MITgcm tutorial_plume_on_slope
Converted from MATLAB gendata.m
"""

import numpy as np

# Precision and byte order settings - use proper NumPy dtype
prec = np.dtype('>f8')  # big-endian 64-bit float (equivalent to MATLAB 'real*8' with 'b')


def write_binary(path, array):
    with open(path, 'wb') as fid:
        np.asarray(array, dtype=prec).ravel(order='F').tofile(fid)

# Dimensions of grid
nx = 320
ny = 1
nz = 60

# Nominal depth of model (meters)
H = 200.0

# Size of domain
Lx = 6.40e3

# Horizontal resolution (m) - variable
res1 = 2/3 * Lx / nx
res2 = 2 * Lx / nx
A = res2 - res1
iswitch1 = 3/4 * nx
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
x = np.cumsum(dx, dtype=np.float64)


import matplotlib.pyplot as plt
plt.figure()
plt.plot(x/1000, dx)
plt.xlabel('X (km)')
plt.ylabel(r'$\Delta x$ (m)')
plt.title('x grid spacing')
plt.xlim([0, 6.5])
plt.grid(True)
plt.show()

z = np.arange(-dz/2, -H-dz/2, -dz)

# Tanh function for cooling
xswitch = 2.50e3 + Lx / 2.0
qwidth = 0.1e3
Q = np.zeros((nx, ny), dtype=np.float64)
for i in range(nx):
    Q[i, :] = Q[i, :] + Qo * 0.5 * (np.tanh((Lx - x[i] - xswitch) / qwidth) + 1)
    # Q[i, :] = Q[i, :] + Qo * 0.5 * (np.tanh((x[i] - xswitch) / qwidth) + 1)  # alternative

plt.figure()
plt.plot(x/1000, Q[:,0])
plt.xlabel('X (km)')
plt.ylabel(r'$Q$ (m)')
plt.title('Heat flux forcing')
plt.xlim([0, 6.5])
plt.grid(True)
plt.show()


# Write Qnet forcing file
write_binary('Qnet.forcing', Q)

# Temperature profile
Tref = Tz * z - np.mean(Tz * z)
#print('Tref =', ', '.join([f'{val:8.6g}' for val in Tref]))

T = 0.01 * np.random.rand(nx, ny, nz)
for k in range(nz):
    T[:, :, k] = T[:, :, k] + Tref[k]

# Write temperature initialization file
write_binary('T.init', T)

# Sloping channel
# tanh function for slope
slope = 0.15
offset = 1.5e3 + Lx / 2.0
dmax = -40.0
hdiff = dmax + H
xwidth = hdiff / (2.0 * slope)

d = np.zeros((nx, ny), dtype=np.float64)
for i in range(nx):
    for j in range(ny):
        # d[i, j] = hdiff/2 * (np.exp((x[i]-offset)/xwidth) - np.exp(-(x[i]-offset)/xwidth)) / (np.exp((x[i]-offset)/xwidth) + np.exp(-(x[i]-offset)/xwidth)) + hdiff/2 - H
        d[i, j] = hdiff / 2 * (np.tanh((Lx - x[i] - offset) / xwidth) + 1) - H

d[0, :] = 0.0

# Write topography file
write_binary('topog.slope', d)

# Plot the bathymetry
plt.figure()
plt.plot(x/1000, d[:, 0])
plt.xlabel('x (km)')
plt.ylabel('Depth (m)')
plt.title('Bathymetry Profile')
plt.xlim([0, 6.5])
plt.grid(True)
plt.show()

# Write dx spacing file
write_binary('dx.bin', dx)

print(f"dx range: {np.min(dx):.6f} to {np.max(dx):.6f} m")
print(f"Temperature range: {np.min(T):.6f} to {np.max(T):.6f}")
print(f"Bathymetry range: {np.min(d):.6f} to {np.max(d):.6f} m")
print(f"Q forcing range: {np.min(Q):.6f} to {np.max(Q):.6f}")