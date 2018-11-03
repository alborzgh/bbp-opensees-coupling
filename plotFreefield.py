#!/usr/bin/python2.7

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
import sys
from scipy import interpolate

# setup matplotlib for latex encoding
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['text.latex.unicode'] = True



wd = "./"
motionDir = sys.argv[1]

isRigidBase = False

# read node info
nodeInfo = np.loadtxt(wd + "nodesInfo.dat")
nodesY = nodeInfo[0::4,2]
elemY  = 0.5 * (nodesY[0:-1] + nodesY[1:])

# read base acceleration
baseTimeData = np.loadtxt(wd + motionDir + ".time")
baseAccData  = np.loadtxt(wd + motionDir + "X.acc")

# read relative acceleration
relAccData  = np.loadtxt(wd + "acceleration.out")
relTimeData = relAccData[:,0]

# interpolate base acceleraion with recorded time
baseTimeInterp = interpolate.interp1d(baseTimeData, baseAccData, kind = 'linear', fill_value='extrapolate' )

# plot motion at surface
if isRigidBase:
        surfMotion = relAccData[:,relAccData.shape[1]-3] / 9.81 + baseTimeInterp(relTimeData)
else:
        surfMotion = relAccData[:,relAccData.shape[1]-3] / 9.81

if isRigidBase:
        profile_pga = np.amax(np.abs(relAccData[:,1::12].transpose() / 9.81 + baseTimeInterp(relTimeData)) ,axis = 1)
else:
        profile_pga = np.amax(np.abs(relAccData[:,1::12].transpose() / 9.81) ,axis = 1)


# read stress file
stress = np.loadtxt(wd + "stress.out")
stress_time = stress[:,0]
bot_tau = stress[:,4]
top_tau = stress[:,-3]
profile_sig_v = np.amax(np.abs(stress[:,4::6]), axis=0)
profile_sig_v /= stress[0,2::6]

# read strain file
strain = np.loadtxt(wd + "strain.out")
strain_time = strain[:,0]
bot_gam = strain[:,4]
top_gam = strain[:,-3]
profile_gam_max = np.amax(np.abs(strain[:,4::6]), axis=0) * 100.0



# plot acceleration
plt.figure()
plt.plot(baseTimeData, baseAccData, label="Base Motion")
plt.plot(relTimeData, surfMotion, label="Surface Motion")
plt.grid(b = True, which = 'major', axis = 'both', 
        color = (0.5, 0.5, 0.5, 0.5), linestyle = ':', 
        linewidth = 0.7)
plt.grid(b = True, which = 'minor', axis = 'both', 
        color = (0.8, 0.8, 0.8, 0.5), linestyle = ':', 
        linewidth = 0.5)
plt.legend()
plt.xlabel("time (s)")
plt.ylabel("Acceleration (g)")
plt.rc('text', usetex=True)
plt.rc('font', family='serif', serif='Computer Modern Roman')
plt.savefig(wd + 'accTH.pdf')
plt.show(block = False)

# plot stress strain
plt.figure()
plt.plot(bot_gam * 100.0, bot_tau, label="Bottom element")
plt.grid(b = True, which = 'major', axis = 'both', 
        color = (0.5, 0.5, 0.5, 0.5), linestyle = ':', 
        linewidth = 0.7)
plt.grid(b = True, which = 'minor', axis = 'both', 
        color = (0.8, 0.8, 0.8, 0.5), linestyle = ':', 
        linewidth = 0.5)
plt.legend()
plt.xlabel(r"$\gamma (\%)$")
plt.ylabel(r"$\tau (\mathrm{kPa})$")
plt.rc('text', usetex=True)
plt.rc('font', family='serif', serif='Computer Modern Roman')
plt.savefig(wd + 'bot_stressstrain.pdf')
plt.show(block = False)

# plot stress strain
plt.figure()
plt.plot(top_gam * 100.0, top_tau, label="Top Element")
plt.grid(b = True, which = 'major', axis = 'both', 
        color = (0.5, 0.5, 0.5, 0.5), linestyle = ':', 
        linewidth = 0.7)
plt.grid(b = True, which = 'minor', axis = 'both', 
        color = (0.8, 0.8, 0.8, 0.5), linestyle = ':', 
        linewidth = 0.5)
plt.legend()
plt.xlabel(r"$\gamma (\%)$")
plt.ylabel(r"$\tau (kPa)$")
plt.rc('text', usetex=True)
plt.rc('font', family='serif', serif='Computer Modern Roman')
plt.savefig(wd + 'topStressStrain.pdf')
plt.show(block = False)

# plot stress strain
plt.figure()
plt.plot(np.abs(profile_sig_v), elemY)
plt.grid(b = True, which = 'major', axis = 'both', 
        color = (0.5, 0.5, 0.5, 0.5), linestyle = ':', 
        linewidth = 0.7)
plt.grid(b = True, which = 'minor', axis = 'both', 
        color = (0.8, 0.8, 0.8, 0.5), linestyle = ':', 
        linewidth = 0.5)
plt.xlabel("CSR")
plt.ylabel("Elevation (m)")
plt.rc('text', usetex=True)
plt.rc('font', family='serif', serif='Computer Modern Roman')
plt.xlim((0.0,1.0))
plt.savefig(wd + 'CSR_Profile.pdf')
plt.show(block = False)

# plot stress strain
plt.figure()
plt.plot(profile_gam_max, elemY)
plt.grid(b = True, which = 'major', axis = 'both', 
        color = (0.5, 0.5, 0.5, 0.5), linestyle = ':', 
        linewidth = 0.7)
plt.grid(b = True, which = 'minor', axis = 'both', 
        color = (0.8, 0.8, 0.8, 0.5), linestyle = ':', 
        linewidth = 0.5)
plt.xlabel(r"$\gamma_{xy,\max} (\%)$")
plt.ylabel("Elevation (m)")
plt.rc('text', usetex=True)
plt.rc('font', family='serif', serif='Computer Modern Roman')
plt.savefig(wd + 'Gmax_Profile.pdf')
plt.show(block = False)

# plot stress strain
plt.figure()
plt.plot(profile_pga, nodesY)
plt.grid(b = True, which = 'major', axis = 'both', 
        color = (0.5, 0.5, 0.5, 0.5), linestyle = ':', 
        linewidth = 0.7)
plt.grid(b = True, which = 'minor', axis = 'both', 
        color = (0.8, 0.8, 0.8, 0.5), linestyle = ':', 
        linewidth = 0.5)
plt.xlabel("PGA (g)")
plt.ylabel("Elevation (m)")
plt.rc('text', usetex=True)
plt.rc('font', family='serif', serif='Computer Modern Roman')
plt.savefig(wd + 'PGA_Profile.pdf')
plt.show(block = False)

plt.show()
