#======================================================
# parrotdiff.d - Type C Differentially Rotating NS
# Configuration: λ₁ = 1.5, λ₂ = 0.5
# EOS: DD2 (CompOSE)
# Expected result: M_g ≈ 2.94 M_sun
#======================================================

#------------------------------------------------------
# ITERATION PARAMETERS
#------------------------------------------------------
500 mer_max
1.e-8 precis
10 mer_rot
50. freq_ini_si
50 mer_change_omega
100 mer_fix_omega
10 delta_mer_kep
0.5 thres_adapt
0.5 relax
500 mermax_poisson
0.6 relax_poisson
1.e-12 precis_adapt

#------------------------------------------------------
# MULTI-DOMAIN SPECTRAL GRID
#------------------------------------------------------
4 nz
2 nzet
1 nzadapt
17 nt
1 np
33 0.
33 5.
25 12.
17 25.
0.05 enthalpy_boundary

#------------------------------------------------------
# PHYSICAL PARAMETERS
#------------------------------------------------------
1 relativity
0.28 ent_c
500.0 freq_si
2.0 rotation_type

# KEY DIFFERENCE: λ₁ = 1.5 (weaker differential rotation)
1.5 lambda_1

0.5 lambda_2
1.0 A2_initial
0.5 B2_initial
1.01 fact_omega
3.0 M_baryon_target

#======================================================
# EXPECTED OUTPUT (DD2 EOS, Type C λ₁=1.5)
#======================================================
# Gravitational mass:  M_g = 2.94 M_sun
# Baryonic mass:       M_b = 3.40 M_sun
# Circ. radius:        R_circ = 15.65 km
# Axis ratio:          r_p/r_eq = 0.484
# Central frequency:   f_c = 1832 Hz
# Equatorial freq.:    f_eq = 911 Hz
# Max frequency:       f_max = 2709 Hz
# T/|W|:               0.187 (secularly unstable)
# GRV2:                ~0.66%
# GRV3:                ~0.46%
# Mass enhancement:    +21.5% above TOV (2.42 M_sun)
#
# COMPARISON TO λ₁=2.0:
# - Lower mass (2.94 vs 2.97 M_sun)
# - Larger radius (15.65 vs 15.09 km)
# - Less oblate (0.484 vs 0.454 axis ratio)
# - Higher T/|W| (0.187 vs 0.176)
# - Better convergence (lower virial errors)
#======================================================
