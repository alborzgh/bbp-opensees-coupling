# site response configuration file


# general constants
set g     -9.81
set pi     3.141592654

#-----------------------------------------------------------------------------------------
#  1. DEFINE GEOMETRY
#-----------------------------------------------------------------------------------------

# thickness of soil profile
set soilThick       18.0

# grade of slope (%)
set grade           0.0

# number of soil layers
set numLayers       5

# layer thickness - botoom to top
set layerThick(5)   2.0
set layerThick(4)   6.0
set layerThick(3)   5.0
set layerThick(2)   2.4
set layerThick(1)   2.6

# depth of water table
set waterTable      0.0

#-----------------------------------------------------------------------------------------
#  2. DEFINE FINITE ELEMENT MESH
#-----------------------------------------------------------------------------------------

# number of elements in horizontal direction
set nElemX  1
set nElemZ  1

# horizontal element size
set sElemX  1.0
set sElemZ  1.0

# number of elements in vertical direction for each layer
set nElemY(5)  4
set nElemY(4)  12
set nElemY(3)  5
set nElemY(2)  2
set nElemY(1)  2

# total number of elements in vertical direction
set nElemT     25

#-----------------------------------------------------------------------------------------
#  3. DEFINE MOTION
#-----------------------------------------------------------------------------------------

# number of directions for application of the motion
set numDir 2

# motion file (used if the input arguments do not include motion)
set accFile  Motion3.acc
set velFile  Motion3.vel
set timeFile Motion3.time

# define motion time step
set useMotionDT true
set motionDT 1000.0; # used if useMotionDT is false

# define base
set isRigidBase false

# if compliant define the base (used if isRigidBase is false)
set rockVS  1000.0
set rockVP  3000.0
set rockDen 2.5

#-----------------------------------------------------------------------------------------
#  4. MODEL
#-----------------------------------------------------------------------------------------

# effective/total stress
set isEffetive false

# choose element type
set IsSSP true 

# RAYLEIGH DAMPING PARAMETERS
set damp    0.03
# set omega1  [expr 2.0 * $pi * 1.0]	
# set omega2  [expr 2.0 * $pi * 10.0]	

set omega1  14.83	
set omega2  74.14

# recorder time step
set useMotionDTforRec true
set recDT  0.001; # used if useMotionDTforRec is false

#-----------------------------------------------------------------------------------------
#  4. ANALYSIS OPTIONS
#-----------------------------------------------------------------------------------------

# gravity analysis
set grav_cons    "Penalty 1.0e15 1.0e15"
set grav_test    "NormDispIncr 1e-5 30 1"
set grav_algo    "KrylovNewton"
set grav_numb    "Plain"
set grav_syst    "Mumps"
set grav_intg    "Newmark [expr 5.0/6.0] [expr 4.0/9.0]"
set grav_anls    "Transient"

set grav_elasticAnalysisDT 500.0
set grav_elasticAnalysisNo 20
set grav_plasticAnalysisDT 5.0e-2
set grav_plasticAnalysisNo 40


# transient analysis
set trans_cons   "Penalty 1.0e14 1.0e14"
set trans_test   "NormDispIncr 5.0e-4 30 1"
set trans_algo   "Newton"
set trans_numb   "Plain"
set trans_syst   "Mumps"
set trans_intg   "Newmark 0.5 0.25"
set trans_anls   "Transient"
