#!/bin/bash

# unofficial bash strict mode
set -euo pipefail
IFS=$'\n\t'

# load the environment variables related to BBP
source ~/.bash_profile

# setup variables pointing to file names
BBPEXE="/home/alborzgh/broadband/bbp-17.3.0/bbp/comps/run_bbp.py"
LOG="./run_log.log"
OPT_FILE="./bbp_option.opt"

# run BBP
RUN_CMD="$BBPEXE -o $OPT_FILE -l $LOG"
echo "##########################"
echo "Running BroadBand Platform"
echo "##########################"
echo ""
echo $RUN_CMD
#eval $RUN_CMD

# read where the results are written
OUT_PATH="`./readLog.py $LOG`"
echo "Results are written in $OUT_PATH"

# copy velocity and acceleration files to run index
RUN_IND=${OUT_PATH##*/}
if ! [ -e "$RUN_IND" ]; then
    mkdir $RUN_IND
fi
echo "Copying acceleration and velocity time histories to $RUN_IND"
eval "cp $OUT_PATH/*.vel.bbp $RUN_IND"
eval "cp $OUT_PATH/*.acc.bbp $RUN_IND"

# create readable files for OpenSees
echo "Generating OpenSees readable motions"
STATIONS="`./processMotions.py $RUN_IND`"

# run OpenSees
OPENSEES_EXE="OpenSeesSP"

for station in $STATIONS
do

FFSCRIPT="./freefield/FreeField3D_UW.tcl"
CONFIGFILE="./freefield/${station}.tcl"
MATFILE="./freefield/${station}_mat.tcl"
OS_CMD="${OPENSEES_EXE} ${FFSCRIPT} ${CONFIGFILE} ${MATFILE} ./${RUN_IND}/$station 1>>OS.log 2>&1"

echo "#########################################"
echo "Running Freefield Analysis using OpenSees"
echo "Station : $station"
echo "#########################################"
echo $OS_CMD
eval $OS_CMD

# generate plots
echo "Generating plots of results"
./plotFreefield.py ./${RUN_IND}/nwhp
done