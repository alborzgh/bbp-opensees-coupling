# ##########################################################
#                                                         #
# 3D site response analysis of a soil deposit on an       #
# elastic half-space.  Shaking is applied in a single     #
# plane, and the site has a slope out of the plane of     #
# shaking.  The finite rigidity of the underlying medium  #
# is considered through the use of a viscous damper at    #
# the base of the soil column.                            #
#                                                         #
#   Created by:  Chris McGann                             #
#                Pedro Arduino                            #
#              --University of Washington--               #
#                                                         #
#   Revamped by Alborz Ghofrani                           #
#                                                         #
###########################################################

wipe

# check if the script was called with input arguments
switch $argc {
	0 {
		set modelConfFile "freefield_config.tcl"
		set matFile       "freefield_material.tcl"
		set motionNameSet false
	}
	1 {
		set modelConfFile "freefield_config.tcl"
		set matFile       [lindex $argv 0]
		set motionNameSet false
	}
	2 {
		set modelConfFile [lindex $argv 0]
		set matFile       [lindex $argv 1]
		set motionNameSet false
	}
	3 {
		set modelConfFile [lindex $argv 0]
		set matFile       [lindex $argv 1]
		set motionName    [lindex $argv 2]
		set motionNameSet true
	}
	default {
		set modelConfFile "freefield_config.tcl"
		set matFile       "freefield_material.tcl"
		set motionNameSet false
	}
}

puts "Configuration is read from $modelConfFile"
puts "Material Properties are read from $matFile"
if {$motionNameSet} {
	puts "Motion name is $motionName"
}


# ------------------------------------------------
#  1. SETUP THE MODEL
# ------------------------------------------------

# load model configurations
source $modelConfFile

# vertical element size in each layer
for {set i 1} {$i <=$numLayers} {incr i 1} {
    set sElemY($i) [expr $layerThick($i)/$nElemY($i)]
    puts "size:  $sElemY($i)"
}

# number of nodes/elements in vertical direction in each layer
set nNodeT 0
set nElemT 0
for {set k 1} {$k < $numLayers} {incr k 1} {
    set nNodeY($k)  [expr 4*$nElemY($k)]
    puts "number of nodes in layer $k: $nNodeY($k)"
    set nNodeT  [expr $nNodeT + $nNodeY($k)]
	set nElemT  [expr $nElemT + $nElemY($k)]
}
set nNodeY($numLayers) [expr 4*($nElemY($numLayers) + 1)]
puts "number of nodes in layer $numLayers: $nNodeY($numLayers)"

set nNodeT  [expr $nNodeT + $nNodeY($numLayers)]
set nElemT  [expr $nElemT + $nElemY($numLayers)]
puts "total number of nodes:    $nNodeT"
puts "total number of elements: $nElemT"

# ------------------------------------------------
#  2. CREATE SOIL NODES AND BOUNDARY CONDITIONS
# ------------------------------------------------

if {$isEffetive} {
	# for effective analyses I need an extra DOF for pressure
	model BasicBuilder -ndm 3 -ndf 4

	set yCoord  0.0 
	set count   0
	set gwt     1
	set waterHeight [expr $soilThick-$waterTable]
	set nodesInfo [open nodesInfo.dat w]
	# loop over layers
	for {set k 1} {$k <= $numLayers} {incr k 1} {
		# loop over nodes
		for {set j 1} {$j <= $nNodeY($k)} {incr j 4} {
			node  [expr $j+$count]    0.0      $yCoord  0.0
			node  [expr $j+$count+1]  0.0      $yCoord  $sElemZ
			node  [expr $j+$count+2]  $sElemX  $yCoord  $sElemZ
			node  [expr $j+$count+3]  $sElemX  $yCoord  0.0

			puts $nodesInfo "[expr $j+$count]    0.0      $yCoord  0.0"
			puts $nodesInfo "[expr $j+$count+1]  0.0      $yCoord  $sElemZ"
			puts $nodesInfo "[expr $j+$count+2]  $sElemX  $yCoord  $sElemZ"
			puts $nodesInfo "[expr $j+$count+3]  $sElemX  $yCoord  0.0"

			# designate nodes above water table
			if {$yCoord>=$waterHeight} {
				for {set ll 0} {$ll < 4} {incr ll} {
					set dryNode($gwt) [expr $j+$count+$ll]
					incr gwt
				}
			}

			set yCoord  [expr $yCoord + $sElemY($k)]
		}
		set count  [expr $count + $nNodeY($k)]
	}
	close $nodesInfo
	puts "Finished creating all soil nodes..."


	# define boundary conditions for nodes at base of column
	fix 1  1 1 1 0
	fix 2  1 1 1 0
	fix 3  1 1 1 0
	fix 4  1 1 1 0

	# define periodic boundary conditions for remaining nodes
	set count  0
	for {set k 5} {$k <= [expr $nNodeT]} {incr k 4} {
		equalDOF  $k  [expr $k+1]  1 2 3
		equalDOF  $k  [expr $k+2]  1 2 3
		equalDOF  $k  [expr $k+3]  1 2 3
		puts "equalDOF  $k  [expr $k+1]  1 2 3"
		puts "equalDOF  $k  [expr $k+2]  1 2 3"
		puts "equalDOF  $k  [expr $k+3]  1 2 3"
	}

	# define pore pressure boundaries for nodes above water table
	for {set i 1} {$i < $gwt} {incr i 1} {
		fix $dryNode($i)  0 0 0 1
		puts "fix $dryNode($i)  0 0 0 1"
	}
	puts "Finished creating all soil boundary conditions..."

} else {

	model BasicBuilder -ndm 3 -ndf 3

	set yCoord  0.0 
	set count   0
	set nodesInfo [open nodesInfo.dat w]
	# loop over layers
	for {set k 1} {$k <= $numLayers} {incr k 1} {
		# loop over nodes
		for {set j 1} {$j <= $nNodeY($k)} {incr j 4} {
			node  [expr $j+$count]    0.0      $yCoord  0.0
			node  [expr $j+$count+1]  0.0      $yCoord  $sElemZ
			node  [expr $j+$count+2]  $sElemX  $yCoord  $sElemZ
			node  [expr $j+$count+3]  $sElemX  $yCoord  0.0

			puts $nodesInfo "[expr $j+$count]    0.0      $yCoord  0.0"
			puts $nodesInfo "[expr $j+$count+1]  0.0      $yCoord  $sElemZ"
			puts $nodesInfo "[expr $j+$count+2]  $sElemX  $yCoord  $sElemZ"
			puts $nodesInfo "[expr $j+$count+3]  $sElemX  $yCoord  0.0"

			set yCoord  [expr $yCoord + $sElemY($k)]
		}
		set count  [expr $count + $nNodeY($k)]
	}
	close $nodesInfo
	puts "Finished creating all soil nodes..."

	fix 1  1 1 1
	fix 2  1 1 1
	fix 3  1 1 1
	fix 4  1 1 1

	# define periodic boundary conditions for remaining nodes
	set count  0
	for {set k 5} {$k <= [expr $nNodeT]} {incr k 4} {
		equalDOF  $k  [expr $k+1]  1 2 3
		equalDOF  $k  [expr $k+2]  1 2 3
		equalDOF  $k  [expr $k+3]  1 2 3
		puts "equalDOF  $k  [expr $k+1]  1 2 3"
		puts "equalDOF  $k  [expr $k+2]  1 2 3"
		puts "equalDOF  $k  [expr $k+3]  1 2 3"
	}

	puts "Finished creating all soil boundary conditions..."
}

# --------------------------------
#  4. CREATE SOIL MATERIALS
# --------------------------------

set slope [expr atan($grade/100.0)]

# load material properties
source $matFile

for {set k 1} {$k <= $numLayers} {incr k} {
	eval "nDMaterial $mat($k)"
}
puts "Finished creating all soil materials..."

# ---------------------------------------
#  5. CREATE SOIL ELEMENTS
# ---------------------------------------
# set alpha value for SSP element
set count 0
set elemInfo [open elementInfo.dat w]

# loop over layers 
for {set k 1} {$k <= $numLayers} {incr k 1} {
    # loop over elements
    for {set j 1} {$j <= $nElemY($k)} {incr j 1} {
        set nI  [expr 4*($j+$count) - 3] 
        set nJ  [expr $nI + 1]
        set nK  [expr $nI + 2]
        set nL  [expr $nI + 3]
		set nM  [expr $nI + 4]
		set nN  [expr $nI + 5]
		set nO  [expr $nI + 6]
		set nP  [expr $nI + 7]
		if {$isEffetive} {
			if {$IsSSP} {
				element SSPbrickUP [expr $j+$count] $nI $nJ $nK $nL $nM $nN $nO $nP $k $uBulk($k) 1.0 1.0 1.0 1.0 $eInit($k) $alpha $xWgt($k) $yWgt($k) $zWgt($k)
				puts $elemInfo "[expr $j+$count] $nI $nJ $nK $nL $nM $nN $nO $nP $k"
			} else {
				element brickUP [expr $j+$count] $nI $nJ $nK $nL $nM $nN $nO $nP $k [expr $uBulk($k)*(1+$eInit($k))/$eInit($k)] 1.0 1.0 1.0 1.0 $xWgt($k) $yWgt($k) $zWgt($k)
				puts $elemInfo "[expr $j+$count] $nI $nJ $nK $nL $nM $nN $nO $nP $k"
			}
		} else {
			if {$IsSSP} {
				element SSPbrick [expr $j+$count] $nI $nJ $nK $nL $nM $nN $nO $nP $k $xWgt($k) $yWgt($k) $zWgt($k)
				puts $elemInfo "[expr $j+$count] $nI $nJ $nK $nL $nM $nN $nO $nP $k"
			} else {
				element stdBrick [expr $j+$count] $nI $nJ $nK $nL $nM $nN $nO $nP $k $xWgt($k) $yWgt($k) $zWgt($k)
				puts $elemInfo "[expr $j+$count] $nI $nJ $nK $nL $nM $nN $nO $nP $k"
			}
		}
	}
	set count [expr $count + $nElemY($k)]
}
close $elemInfo
puts "Finished creating all soil elements..."

# -----------------------------------------------------
#  8. CREATE GID FLAVIA.MSH FILE FOR POSTPROCESSING
# -----------------------------------------------------
 
set meshFile [open freeField3D.flavia.msh w]
puts $meshFile "MESH ffBrick dimension 3 ElemType Hexahedra Nnode 8"
puts $meshFile "Coordinates"
puts $meshFile "#node_number   coord_x   coord_y   coord_z"
set yCoord  0.0 
set count   0

# loop over layers
for {set k 1} {$k <= $numLayers} {incr k 1} {
	# loop over nodes
	for {set j 1} {$j <= $nNodeY($k)} {incr j 4} {
		puts $meshFile  "[expr $j+$count]    0.0      $yCoord  0.0"
		puts $meshFile  "[expr $j+$count+1]  0.0      $yCoord  $sElemZ"
		puts $meshFile  "[expr $j+$count+2]  $sElemX  $yCoord  $sElemZ"
		puts $meshFile  "[expr $j+$count+3]  $sElemX  $yCoord  0.0"

		set yCoord  [expr $yCoord + $sElemY($k)]
	}
	set count  [expr $count + $nNodeY($k)]
}
puts $meshFile "end coordinates"
puts $meshFile "Elements"
puts $meshFile "# element   node1   node2   node3   node4   node5   node6   node7   node8"
set count 0

# loop over layers 
for {set k 1} {$k <= $numLayers} {incr k 1} {
    # loop over elements
    for {set j 1} {$j <= $nElemY($k)} {incr j 1} {

        set nI  [expr 4*($j+$count) - 3] 
        set nJ  [expr $nI + 1]
        set nK  [expr $nI + 2]
        set nL  [expr $nI + 3]
		set nM  [expr $nI + 4]
		set nN  [expr $nI + 5]
		set nO  [expr $nI + 6]
		set nP  [expr $nI + 7]

        puts $meshFile  "[expr $j+$count] $nI $nJ $nK $nL $nM $nN $nO $nP"
    }
    set count [expr $count + $nElemY($k)]
}
puts $meshFile "end elements"
close $meshFile

# ---------------------------
#  7. GRAVITY RECORDERS
# ---------------------------

# record nodal displacments, velocities, and accelerations at each time step
recorder Node -file Gdisplacement.out -time  -nodeRange 1 $nNodeT -dof 1 2 3 disp
recorder Node -file Gvelocity.out     -time  -nodeRange 1 $nNodeT -dof 1 2 3 vel
recorder Node -file Gacceleration.out -time  -nodeRange 1 $nNodeT -dof 1 2 3 accel
recorder Node -file Greaction.out     -time  -nodeRange 1 $nNodeT -dof 1 2 3 4 reaction
if {$isEffetive} {
	recorder Node -file GporePressure.out -time  -nodeRange 1 $nNodeT -dof 4 vel
}

# record stress and strain at each gauss point in the soil elements
if {$IsSSP} {	
	recorder Element -file Gstress.out   -time  -eleRange  1   $nElemT  stress 6
	recorder Element -file Gstrain.out   -time  -eleRange  1   $nElemT  strain
} else {
	recorder Element -file Gstress1.out   -time  -eleRange  1   $nElemT  material 1 stress 6
	recorder Element -file Gstress2.out   -time  -eleRange  1   $nElemT  material 2 stress 6
	recorder Element -file Gstress3.out   -time  -eleRange  1   $nElemT  material 3 stress 6
	recorder Element -file Gstress4.out   -time  -eleRange  1   $nElemT  material 4 stress 6
	recorder Element -file Gstress5.out   -time  -eleRange  1   $nElemT  material 5 stress 6
	recorder Element -file Gstress6.out   -time  -eleRange  1   $nElemT  material 6 stress 6
	recorder Element -file Gstress7.out   -time  -eleRange  1   $nElemT  material 7 stress 6
	recorder Element -file Gstress8.out   -time  -eleRange  1   $nElemT  material 8 stress 6
	
	recorder Element -file Gstrain1.out   -time  -eleRange  1   $nElemT  material 1 strain 
	recorder Element -file Gstrain2.out   -time  -eleRange  1   $nElemT  material 2 strain 
	recorder Element -file Gstrain3.out   -time  -eleRange  1   $nElemT  material 3 strain 
	recorder Element -file Gstrain4.out   -time  -eleRange  1   $nElemT  material 4 strain 
	recorder Element -file Gstrain5.out   -time  -eleRange  1   $nElemT  material 5 strain 
	recorder Element -file Gstrain6.out   -time  -eleRange  1   $nElemT  material 6 strain 
	recorder Element -file Gstrain7.out   -time  -eleRange  1   $nElemT  material 7 strain 
	recorder Element -file Gstrain8.out   -time  -eleRange  1   $nElemT  material 8 strain 
}
puts "Finished creating gravity recorders..."


# -------------------------
#  7. GRAVITY ANALYSIS
# -------------------------

# damping coefficients
set a0      [expr 2*$damp*$omega1*$omega2/($omega1 + $omega2)]
set a1      [expr 2*$damp/($omega1 + $omega2)]
puts "damping coefficients: a_0 = $a0;  a_1 = $a1"

# update materials to consider elastic behavior
for {set k 1} {$k <= $numLayers} {incr k} {
    updateMaterialStage -material $k -stage 0
}

eval "constraints $grav_cons "
eval "test        $grav_test "
eval "algorithm   $grav_algo"
eval "numberer    $grav_numb"
eval "system      $grav_syst"
eval "integrator  $grav_intg  "
eval "rayleigh    $a0 0.0 $a1 0.0"
eval "analysis    $grav_anls"

set startT  [clock seconds]
if {$grav_anls == "Static"} {
	analyze $grav_elasticAnalysisNo
} else {
	analyze $grav_elasticAnalysisNo $grav_elasticAnalysisDT
}

puts "Finished with elastic gravity analysis..."

# update materials to consider plastic behaviour
for {set k 1} {$k <= $numLayers} {incr k} {
    updateMaterialStage -material $k -stage 1
}

set lowerElem 0
set upperElem 0

# update poissonRatio for dynamic analysis
for {set i 1} {$i <= $numLayers} {incr i} {
	set lowerElem [expr $upperElem  + 1]
	set upperElem [expr $upperElem + $nElemY($i)]
	if {$updateVoidRatio($i)} {
		setParameter -value $eInit($i) -eleRange $lowerElem $upperElem voidRatio $i
	}
	if {$updatePoissonRatio($i)} {
		setParameter -value $poisson($i) -eleRange $lowerElem $upperElem poissonRatio $i
	}
}

# plastic gravity loading
if {$grav_anls == "Static"} {
	analyze $grav_plasticAnalysisNo
} else {
	analyze $grav_plasticAnalysisNo $grav_plasticAnalysisDT
}

puts "Finished with plastic gravity analysis..."

if {!$isRigidBase} {
	for {set ii 1} {$ii <= 4} {incr ii} {
		if {$numDir == 1} {
			remove sp $ii 1
		}
		if {$numDir == 2} {
			remove sp $ii 1
			remove sp $ii 3
		}
		if {$numDir == 3} {
			remove sp $ii 1
			remove sp $ii 2
			remove sp $ii 3
		}
	}

	if {$numDir == 1} {
		equalDOF 1 2 1
		equalDOF 1 3 1 
		equalDOF 1 4 1
	}
	if {$numDir == 2} {
		equalDOF 1 2 1 3
		equalDOF 1 3 1 3 
		equalDOF 1 4 1 3
	}
	if {$numDir == 3} {
		equalDOF 1 2 1 2 3
		equalDOF 1 3 1 2 3 
		equalDOF 1 4 1 2 3
		
		eval "pattern Plain 20 {Path -time {0.0 1.0e10} -values {1.0 1.0} -factor 1.0} {
			load 1   [nodeReaction 1]
			load 2   [nodeReaction 2]
			load 3   [nodeReaction 3]
			load 4   [nodeReaction 4]
		}"
	}
	
}

# --------------------------------------------------------------------
#  11. UPDATE ELEMENT PERMEABILITY VALUES FOR POST-GRAVITY ANALYSIS
# --------------------------------------------------------------------
if {$isEffetive} {
	set lowerElem 0
	set upperElem 0

	for {set i 1} {$i <= $numLayers} {incr i} {
		set lowerElem [expr $upperElem  + 1]
		set upperElem [expr $upperElem + $nElemY($i)]
		if {$IsSSP} {
			setParameter -value $hPerm($i) -eleRange $lowerElem $upperElem xPerm
			setParameter -value $vPerm($i) -eleRange $lowerElem $upperElem yPerm
			setParameter -value $hPerm($i) -eleRange $lowerElem $upperElem zPerm
		} else {
			setParameter -value $hPerm($i) -eleRange $lowerElem $upperElem hPerm
			setParameter -value $vPerm($i) -eleRange $lowerElem $upperElem vPerm
		}
	}
	puts "Finished updating permeabilities for dynamic analysis..."
}

# -------------------------------------
#  8. CREATE POST-GRAVITY RECORDERS
# -------------------------------------
# reset time and analysis
setTime 0.0
wipeAnalysis
remove recorders

## record nodal displacments, velocities, and accelerations at each time step
recorder Node -file displacement.out -time -dT $recDT  -nodeRange 1 $nNodeT -dof 1 2 3 disp
recorder Node -file velocity.out     -time -dT $recDT  -nodeRange 1 $nNodeT -dof 1 2 3 vel
recorder Node -file acceleration.out -time -dT $recDT  -nodeRange 1 $nNodeT -dof 1 2 3 accel
if {$isEffetive} {
	recorder Node -file porePressure.out -time -dT $recDT  -nodeRange 1 $nNodeT -dof 4 vel
}

# record stress and strain at each gauss point in the soil elements
if {$IsSSP} {
	recorder Element -file stress.out   -time -dT $recDT -eleRange  1   $nElemT  stress 6
	recorder Element -file strain.out   -time -dT $recDT -eleRange  1   $nElemT  strain
} else {
	recorder Element -file stress1.out  -time -dT $recDT -eleRange  1   $nElemT  material 1 stress 6
	recorder Element -file stress2.out  -time -dT $recDT -eleRange  1   $nElemT  material 2 stress 6
	recorder Element -file stress3.out  -time -dT $recDT -eleRange  1   $nElemT  material 3 stress 6
	recorder Element -file stress4.out  -time -dT $recDT -eleRange  1   $nElemT  material 4 stress 6
	recorder Element -file stress5.out  -time -dT $recDT -eleRange  1   $nElemT  material 5 stress 6
	recorder Element -file stress6.out  -time -dT $recDT -eleRange  1   $nElemT  material 6 stress 6
	recorder Element -file stress7.out  -time -dT $recDT -eleRange  1   $nElemT  material 7 stress 6
	recorder Element -file stress8.out  -time -dT $recDT -eleRange  1   $nElemT  material 8 stress 6

	recorder Element -file strain1.out  -time -dT $recDT -eleRange  1   $nElemT  material 1 strain
	recorder Element -file strain2.out  -time -dT $recDT -eleRange  1   $nElemT  material 2 strain
	recorder Element -file strain3.out  -time -dT $recDT -eleRange  1   $nElemT  material 3 strain
	recorder Element -file strain4.out  -time -dT $recDT -eleRange  1   $nElemT  material 4 strain
	recorder Element -file strain5.out  -time -dT $recDT -eleRange  1   $nElemT  material 5 strain
	recorder Element -file strain6.out  -time -dT $recDT -eleRange  1   $nElemT  material 6 strain
	recorder Element -file strain7.out  -time -dT $recDT -eleRange  1   $nElemT  material 7 strain
	recorder Element -file strain8.out  -time -dT $recDT -eleRange  1   $nElemT  material 8 strain
}
puts "Finished creating post-gravity recorders..."


# ------------------------------------
#  9. DEFINE DYNAMIC ANALYSIS PARAMETERS
# ------------------------------------

# set motion file names
if {$motionNameSet} {
	set accFile  "${motionName}.acc"
	set velFile  "${motionName}.vel"
	set timeFile "${motionName}.time"


	if {$numDir > 1} {
		set timeFile "${motionName}.time"
		set accFileX "${motionName}X.acc"
		set accFileY "${motionName}Y.acc"
		set accFileZ "${motionName}Z.acc"
		set velFileX "${motionName}X.vel"
		set velFileY "${motionName}Y.vel"
		set velFileZ "${motionName}Z.vel"
	}
}

# read the motion
puts $timeFile
set channel [open $timeFile r]
set timeVec [split [read -nonewline $channel] \n]
set motionSteps [llength $timeVec]
set motionLen [lindex $timeVec [expr $motionSteps - 1]]
if {$useMotionDT} {
	set t1 [lindex $timeVec 0]
	set t2 [lindex $timeVec 1]
	set motionDT [expr $t2 - $t1]
} else {
	set motionSteps [expr int($motionLen / $motionDT)]
}
close $channel
puts "Number of motion steps: $motionSteps"
puts "Motion time step: $motionDT"
puts "Motion length: $motionLen"
if {$useMotionDTforRec} {
	set recDT $motionDT
}

if {$isRigidBase} {
	if {$numDir > 1} {
		# timeseries object for force history
		set mSeriesX "Path -fileTime $timeFile -filePath $accFileX -factor [expr -$g]"
		set mSeriesZ "Path -fileTime $timeFile -filePath $accFileZ -factor [expr -$g]"

		# loading object
		pattern UniformExcitation 10 1 -accel $mSeriesX
		pattern UniformExcitation 11 3 -accel $mSeriesZ

		if {$numDir > 2} {
			# apply the vertical component
			set mSeriesY "Path -fileTime $timeFile -filePath $accFileY -factor [expr -$g]"
			pattern UniformExcitation 12 2 -accel $mSeriesZ
		}
	} else {
		# timeseries object for force history
		set mSeries "Path -fileTime $timeFile -filePath $accFile -factor [expr -$g]"
		
		# loading object
		pattern UniformExcitation 10 1 -accel $mSeries
	}

} else {
	model BasicBuilder -ndm 3 -ndf 3
	
	# define dashpot nodes
	set dashF [expr $nNodeT+1]
	set dashS [expr $nNodeT+2]

	node $dashF  0.0 0.0 0.0
	node $dashS  0.0 0.0 0.0

	# define fixities for dashpot base node
	fix $dashF  1 1 1

	if {$numDir > 1} {

		# define equal DOF for dashpot and base soil node
		equalDOF 1 $dashS  1 2 3
		puts "Finished creating dashpot nodes and boundary conditions..."

		# define dashpot material
		set colArea        [expr $sElemX*$sElemZ]

		set dashpotCoeffH  [expr $rockVS*$rockDen]
		uniaxialMaterial Viscous [expr $numLayers+1] [expr $dashpotCoeffH*$colArea] 1.0

		# define dashpot element
		element zeroLength [expr $nElemT+1]  $dashF $dashS -mat [expr $numLayers+1]  -dir 1
		element zeroLength [expr $nElemT+3]  $dashF $dashS -mat [expr $numLayers+1]  -dir 3
		puts "Finished creating dashpot material and element..."

		# define constant scaling factor for applied velocity
		set cFactorH [expr $colArea*$dashpotCoeffH]

		# timeseries object for force history
		set mSeriesX "Path -fileTime $timeFile -filePath $velFileX -factor $cFactorH"
		set mSeriesZ "Path -fileTime $timeFile -filePath $velFileZ -factor $cFactorH"

		if {$isEffetive} {
			# loading object
			pattern Plain 10 $mSeriesX {
				load 1  1.0 0.0 0.0 0.0
			}
			pattern Plain 11 $mSeriesZ {
				load 1  0.0 0.0 1.0 0.0
			}
		} else {
			# loading object
			pattern Plain 10 $mSeriesX {
				load 1  1.0 0.0 0.0
			}
			pattern Plain 11 $mSeriesZ {
				load 1  0.0 0.0 1.0
			}
		}
		
		
		if {$numDir > 2} {
			set dashpotCoeffV  [expr $rockVP*$rockDen]
			uniaxialMaterial Viscous [expr $numLayers+2] [expr $dashpotCoeffV*$colArea] 1.0

			element zeroLength [expr $nElemT+2]  $dashF $dashS -mat [expr $numLayers+2]  -dir 2

			set cFactorV [expr $colArea*$dashpotCoeffV]
			set mSeriesY "Path -fileTime $timeFile -filePath $velFileY -factor $cFactorV"

			if {$isEffetive} {
				pattern Plain 12 $mSeriesY {
					load 1  0.0 1.0 0.0 0.0
				}
			} else {
				pattern Plain 12 $mSeriesY {
					load 1  0.0 1.0 0.0 
				}
			}
		}
	} else {
		# define fixities for dashpot model node
		fix $dashS  0 1 1

		# define equal DOF for dashpot and base soil node
		equalDOF 1 $dashS  1
		puts "Finished creating dashpot nodes and boundary conditions..."

		# define dashpot material
		set colArea       [expr $sElemX*$sElemZ]
		set dashpotCoeff  [expr $rockVS*$rockDen]

		uniaxialMaterial Viscous [expr $numLayers+1] [expr $dashpotCoeff*$colArea] 1.0

		# define dashpot element
		element zeroLength [expr $nElemT+1]  $dashF $dashS -mat [expr $numLayers+1]  -dir 1
		puts "Finished creating dashpot material and element..."

		# define constant scaling factor for applied velocity
		set cFactor [expr $colArea*$dashpotCoeff]

		# timeseries object for force history
		set mSeries "Path -fileTime $timeFile -filePath $velFile -factor $cFactor"

		if {$isEffetive} {
			# loading object
			pattern Plain 10 $mSeries {
				load 1  1.0 0.0 0.0 0.0
			}
		} else {
			# loading object
			pattern Plain 10 $mSeries {
				load 1  1.0 0.0 0.0
			}
		}
	}
}
puts "Dynamic loading created..."

eval "constraints $trans_cons "
eval "test        $trans_test "
eval "algorithm   $trans_algo"
eval "numberer    $trans_numb"
eval "system      $trans_syst"
eval "integrator  $trans_intg  "
eval "rayleigh    $a0 0.0 $a1 0.0"
eval "analysis    $trans_anls"


# Set number and length of (pseudo)time steps
set numStep $motionSteps
set dT 	    $motionDT

# Analyze and use substepping if needed
set remStep $numStep
set success 0
proc subStepAnalyze {dT subStep} {
        if {$subStep > 10} {
                return -10
        }
        for {set i 1} {$i < 3} {incr i} {
                puts "Try dT = $dT"
                set success [analyze 1 $dT]
                if {$success != 0} {
                        set success [subStepAnalyze [expr $dT/2.0] [expr $subStep+1]]
                        if {$success == -10} {
                                puts "Did not converge."
                                return success
                        }
                } else {
                        if {$i==1} {
                                puts "Substep $subStep : Left side converged with dT = $dT"
                        } else {
                                puts "Substep $subStep : Right side converged with dT = $dT"
                        }
                }
        }
        return success
}

puts "Start analysis"
set startT [clock seconds]

while {$success != -10} {
        set subStep 0
        set success [analyze $remStep  $dT]
        if {$success == 0} {
                puts "Analysis Finished"
                break
        } else {
                set curTime  [getTime]
                puts "Analysis failed at $curTime . Try substepping."
                set success  [subStepAnalyze [expr $dT/2.0] [incr subStep]]
        set curStep  [expr int($curTime/$dT + 1)]
        set remStep  [expr int($numStep-$curStep)]
                puts "Current step: $curStep , Remaining steps: $remStep"
        }
}
set endT [clock seconds]
puts "loading analysis execution time: [expr $endT-$startT] seconds."

wipe
