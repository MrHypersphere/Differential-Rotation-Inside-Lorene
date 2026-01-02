#======================================================
# par_eos.d - Equation of State Configuration
# EOS: DD2 (GPPVA) from CompOSE Database
#======================================================
#
# EOS Type Codes:
#   1 = Simple polytropic: P = K * rho^Gamma
#   2 = Strange quark matter polytrope
#   9 = CompOSE tabulated EOS (cold neutron star)
#  17 = Multi-polytrope (piecewise)
#
# DD2 Properties:
#   - Relativistic Mean Field model
#   - Density-dependent meson-nucleon couplings
#   - Nuclear incompressibility: K ≈ 243 MeV
#   - Symmetry energy slope: L ≈ 55 MeV
#   - TOV maximum mass: M_TOV ≈ 2.42 M_sun
#   - Classification: Moderately stiff
#
# Source: CompOSE database (compose.obspm.fr)
# Entry: DD2 (GPPVA) - https://compose.obspm.fr/eos/119
#
#======================================================

# EOS type selection
9

# Path to CompOSE EOS directory
# Must contain: eos.nb, eos.thermo
# MODIFY THIS PATH to match your installation:
Eos/CompOSE/DD2/

#======================================================
# REQUIRED FILES IN EOS DIRECTORY:
#
# eos.nb - Baryon number density table
#   Format: nb [fm^-3] as function of (T, Y_q, n_B)
#   For cold NS: T=0, Y_q=Y_e (beta equilibrium)
#
# eos.thermo - Thermodynamic quantities
#   Columns typically include:
#   - Pressure P [MeV/fm^3]
#   - Energy density e [MeV/fm^3]
#   - Entropy s [k_B per baryon]
#   - Chemical potentials mu_n, mu_p [MeV]
#
# Download from: https://compose.obspm.fr/eos/119
#======================================================
#
# ALTERNATIVE EOS OPTIONS:
#
# For polytropic EOS (type 1):
# 1
# 100.0   # K [polytropic constant, cgs]
# 2.0     # Gamma [adiabatic index]
#
# For multi-polytrope (type 17):
# 17
# 3       # Number of segments
# 1.0e14  # rho_1 [g/cm^3]
# 5.0e14  # rho_2 [g/cm^3]
# 1.8     # Gamma_1
# 2.5     # Gamma_2
# 2.0     # Gamma_3
#
#======================================================
