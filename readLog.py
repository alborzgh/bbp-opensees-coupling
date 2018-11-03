#!/usr/bin/python2.7
import sys

if len(sys.argv) > 1:
    logFile = sys.argv[1]
else:
    print("Log File not given!")
    exit()

fHandle = open(logFile, "r")
lastline = fHandle.readlines()[-1].strip()
fHandle.close()

pathIndex = lastline.find('/')
print(lastline[pathIndex:])

# runIndex = lastline.rfind('/') + 1
# print(lastline[runIndex:])