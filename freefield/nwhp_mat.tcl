# material properties for free field analyses

# general constants
set g     -9.81
set pi     3.141592654

# SSP-uP element's alpha
set alpha 1.5e-5

# water bulk modulus
set bf 2.2e6

# material density
set rho(5)			2.05
set rho(4)			1.97
set rho(3)			2.06
set rho(2)			2.06
set rho(1)          2.06

# initial void ratios
set eInit(5)		0.570
set eInit(4)		0.709
set eInit(3)		0.557
set eInit(2)		0.557
set eInit(1)		0.557

# scale permeabilities by g
set permFactor      [expr -1.0/$g]

set hPerm(5) [expr 5.3e-4*$permFactor]
set vPerm(5) [expr 5.3e-4*$permFactor]

set hPerm(4) [expr 1.41e-4*$permFactor]
set vPerm(4) [expr 1.41e-4*$permFactor]

set hPerm(3) [expr 1.20e-4*$permFactor]
set vPerm(3) [expr 1.20e-4*$permFactor]

set hPerm(2) [expr 1.20e-4*$permFactor]
set vPerm(2) [expr 1.20e-4*$permFactor]
 
set hPerm(1) [expr 1.20e-4*$permFactor]
set vPerm(1) [expr 1.20e-4*$permFactor]

for {set k 1} {$k <= $numLayers} {incr k} {
	set updatePoissonRatio($k)   false
	set updateVoidRatio($k)      false

	set xPerm($k) $hPerm($k)
	set yPerm($k) $vPerm($k)
	set zPerm($k) $hPerm($k)

	set xWgt($k)  [expr $g*sin($slope)]
	set yWgt($k)  [expr $g*cos($slope)]
	set zWgt($k)  0.0
	set uBulk($k) [expr $bf]

	set mat($k) "J2CyclicBoundingSurface $k 20000.0 [expr 20000.0 * 2.0 * (1+0.3) / 3.0 / (1.0 - 2.0*0.3)] 200.0 $rho($k) 20000.0 1.0 1e10 0.5"
}