#======================================================
# parrotdiff.d - Type C Differentially Rotating NS
# Configuration: λ₁ = 2.0, λ₂ = 0.5
# EOS: DD2 (CompOSE)
# Expected result: M_g ≈ 2.97 M_sun
#======================================================

#------------------------------------------------------
# ITERATION PARAMETERS
#------------------------------------------------------
# Maximum number of iterations
500 mer_max

# Precision threshold (relative enthalpy change)
# Convergence when diff_ent < precis
1.e-8 precis

# Iteration at which rotation is switched on
# Start non-rotating, then introduce rotation
10 mer_rot

# Initial rotation frequency [Hz] when rotation starts
50. freq_ini_si

# Iteration range for omega ramping
# Frequency ramps from freq_ini_si to freq_si
50 mer_change_omega
100 mer_fix_omega

# Interval for Keplerian frequency search
# (Not needed for Type C - no mass-shedding limit)
10 delta_mer_kep

# Threshold for domain adaptation
0.5 thres_adapt

# Relaxation factor for main iteration
# Lower values improve stability, higher values speed convergence
0.5 relax

# Maximum iterations for Poisson solver
500 mermax_poisson

# Relaxation factor for Poisson solver
0.6 relax_poisson

# Precision for domain adaptation
1.e-12 precis_adapt

#------------------------------------------------------
# MULTI-DOMAIN SPECTRAL GRID
#------------------------------------------------------
# Total number of domains
4 nz

# Number of domains inside the star (containing matter)
2 nzet

# Number of domains with adaptive mapping
1 nzadapt

# Number of points in theta direction
# Must be ODD for spectral transforms
17 nt

# Number of points in phi direction
# 1 = axisymmetric calculation
1 np

# Domain specifications: nr (radial points), r_outer
# Domain 0 (nucleus): nr points, r_min (always 0 for nucleus)
33 0.

# Domain 1 (inner shell): nr points, outer boundary [code units]
33 5.

# Domain 2 (outer shell): nr points, outer boundary
25 12.

# Domain 3 (external): nr points, outer boundary
17 25.

# Enthalpy value at boundary between domains 0 and 1
# LORENE rescales domains during iteration to track surface
0.05 enthalpy_boundary

#------------------------------------------------------
# PHYSICAL PARAMETERS
#------------------------------------------------------
# Relativity flag: 1 = General Relativity, 0 = Newtonian
1 relativity

# Central enthalpy in units of c^2
# H_c = 0.28 c^2 yields maximum stable mass for DD2
0.28 ent_c

# Target rotation frequency [Hz]
500.0 freq_si

# Differential rotation type
# 0 = uniform (Omega = const)
# 1 = KEH law
# 2 = Uryu law (Type A, B, C depending on lambda values)
2.0 rotation_type

# Uryu rotation law parameters
# lambda_1: Controls radial differential rotation strength
# Larger values produce stronger shear, more pronounced off-center peak
2.0 lambda_1

# lambda_2 = Omega_eq / Omega_c: Latitudinal parameter
# Values < 1 mean equatorial surface rotates slower than center
0.5 lambda_2

# Shape parameters A^2 and B^2 for Uryu law
# These control the rotation profile shape
1.0 A2_initial
0.5 B2_initial

# Factor for Keplerian frequency search
# 1.01 allows approaching mass-shedding limit
# (Type C doesn't reach this limit)
1.01 fact_omega

# Target baryonic mass [M_sun]
# Used as initial guess; actual mass determined by ent_c
3.0 M_baryon_target

#======================================================
# EXPECTED OUTPUT (DD2 EOS, Type C λ₁=2.0)
#======================================================
# Gravitational mass:  M_g = 2.97 M_sun
# Baryonic mass:       M_b = 3.45 M_sun
# Circ. radius:        R_circ = 15.09 km
# Axis ratio:          r_p/r_eq = 0.454
# Central frequency:   f_c = 1823 Hz
# Equatorial freq.:    f_eq = 906 Hz
# Max frequency:       f_max = 3646 Hz
# T/|W|:               0.176 (secularly unstable)
# GRV2:                ~1.18%
# GRV3:                ~0.92%
# Mass enhancement:    +22.7% above TOV (2.42 M_sun)
#======================================================
