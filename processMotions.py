#!/usr/bin/python2.7
from os import listdir
import sys
import numpy as np

if len(sys.argv) > 1:
    motionID = sys.argv[1]
else:
    print("Motion ID not given!")
    exit()

files = [f for f in listdir("./"+motionID)]

for f in files:
    if f.find("acc.bbp") > -1:
        stationName = f.replace(str(motionID)+".","").replace(".acc.bbp","")
        
        data = np.loadtxt("./" + motionID + "/" + f)
        time = data[:,0]
        accX = data[:,1] / 981.0
        accY = data[:,3] / 981.0
        accZ = data[:,2] / 981.0

        np.savetxt("./" + motionID + "/" + stationName + ".time", time)
        np.savetxt("./" + motionID + "/" + stationName + "X.acc", accX)
        np.savetxt("./" + motionID + "/" + stationName + "Y.acc", accY)
        np.savetxt("./" + motionID + "/" + stationName + "Z.acc", accZ)

        #print("Processed Acceleration Files for Station {0} From File {1}").format(stationName, f)

    elif f.find("vel.bbp") > -1:
        stationName = f.replace(motionID+".","").replace(".vel.bbp","")
        
        data = np.loadtxt("./" + motionID + "/" + f)
        time = data[:,0]
        velX = data[:,1] / 100.0
        velY = data[:,3] / 100.0
        velZ = data[:,2] / 100.0

        np.savetxt("./" + motionID + "/" + stationName + ".time", time)
        np.savetxt("./" + motionID + "/" + stationName + "X.vel", velX)
        np.savetxt("./" + motionID + "/" + stationName + "Y.vel", velY)
        np.savetxt("./" + motionID + "/" + stationName + "Z.vel", velZ)

        #print("Processed Velocity Files for Station {0} From File {1}").format(stationName, f)
        print(stationName)
