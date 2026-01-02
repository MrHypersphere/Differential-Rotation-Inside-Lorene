# LORENE Installation and Configuration Guide

This guide provides step-by-step instructions for installing and configuring LORENE (Langage Objet pour la Relativité Numérique) for differentially rotating neutron star simulations.

## Table of Contents

1. [Overview](#overview)
2. [System Requirements](#system-requirements)
3. [Dependencies Installation](#dependencies-installation)
4. [LORENE Installation](#lorene-installation)
5. [EOS Configuration](#eos-configuration)
6. [Running nrotdiff](#running-nrotdiff)
7. [Parameter Files](#parameter-files)
8. [Troubleshooting](#troubleshooting)

---

## Overview

**LORENE** is a spectral methods library developed at the Observatoire de Paris-Meudon for solving partial differential equations in the context of astrophysical applications, particularly neutron star and black hole simulations.

**Key Resources:**
- **Official Website:** [https://lorene.obspm.fr](https://lorene.obspm.fr)
- **Source Code:** [https://lorene.obspm.fr/download.html](https://lorene.obspm.fr/download.html)
- **Documentation:** [https://lorene.obspm.fr/DOC/html/index.html](https://lorene.obspm.fr/DOC/html/index.html)
- **Source Code Library:** [Astrophysics Source Code Library (ascl:1608.018)](https://ascl.net/1608.018)

### Why Spectral Methods?

LORENE employs multi-domain spectral methods:
- Functions are expanded in Chebyshev polynomials (radial) and spherical harmonics (angular)
- Achieves exponential convergence for smooth solutions
- Naturally handles coordinate singularities at stellar center
- Efficiently resolves asymptotic falloff at spatial infinity

---

## System Requirements

### Hardware
- **RAM:** Minimum 8 GB (16+ GB recommended for high-resolution runs)
- **Storage:** ~5 GB for full installation with EOS tables
- **CPU:** Multi-core processor recommended

### Operating System
- Linux (Ubuntu 20.04+, Debian, CentOS, or equivalent)
- macOS (with Homebrew)
- WSL2 on Windows (Ubuntu recommended)

### Compiler
- GCC 7+ or Clang 10+
- C++11 standard support required

---

## Dependencies Installation

### Ubuntu/Debian

```bash
# Update package lists
sudo apt-get update

# Install essential build tools
sudo apt-get install -y build-essential gfortran

# Install required libraries
sudo apt-get install -y libfftw3-dev libgsl-dev

# Install optional visualization (PGPLOT)
sudo apt-get install -y pgplot5

# Install additional utilities
sudo apt-get install -y wget git cmake
```

### CentOS/RHEL/Fedora

```bash
# Install development tools
sudo dnf groupinstall "Development Tools"
sudo dnf install gcc-gfortran

# Install required libraries
sudo dnf install fftw-devel gsl-devel

# Install PGPLOT (may need EPEL)
sudo dnf install epel-release
sudo dnf install pgplot
```

### macOS (Homebrew)

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install gcc fftw gsl
brew install pgplot  # Optional
```

### Verify Dependencies

```bash
# Check FFTW installation
pkg-config --libs fftw3
# Expected: -lfftw3

# Check GSL installation
pkg-config --libs gsl
# Expected: -lgsl -lgslcblas -lm

# Check Fortran compiler
gfortran --version
```

---

## LORENE Installation

### Step 1: Download LORENE

```bash
# Create installation directory
mkdir -p ~/software
cd ~/software

# Download LORENE (check website for latest version)
wget https://lorene.obspm.fr/download/Lorene_release.tar.gz

# Extract archive
tar -xzf Lorene_release.tar.gz
cd Lorene

# Set environment variable
export HOME_LORENE=$(pwd)
echo "export HOME_LORENE=$HOME_LORENE" >> ~/.bashrc
```

**Alternative: Git Repository**
```bash
# If available via git
git clone https://gitlab.obspm.fr/music/lorene.git
cd lorene
export HOME_LORENE=$(pwd)
```

### Step 2: Configure LORENE

Create the configuration file `local_settings`:

```bash
cd $HOME_LORENE
cp local_settings_linux local_settings  # Linux
# OR
cp local_settings_macos local_settings  # macOS
```

Edit `local_settings` to match your system:

```makefile
# local_settings for Ubuntu/Debian
#----------------------------------

# C++ compiler
CXX = g++

# C++ flags
CXXFLAGS = -O2 -DNDEBUG

# Fortran compiler
F77 = gfortran

# Fortran flags
F77FLAGS = -O2

# C++ flags for shared library
CXXFLAGS_EXPORT = -fPIC

# Ranlib command
RANLIB = ranlib

# Path to FFTW3
FFTW_INCLUDE = /usr/include
FFTW_LIB = /usr/lib/x86_64-linux-gnu

# Path to GSL
GSL_INCLUDE = /usr/include
GSL_LIB = /usr/lib/x86_64-linux-gnu

# Path to PGPLOT (optional)
PGPLOT_INCLUDE = /usr/include
PGPLOT_LIB = /usr/lib

# Lapack library flags
LAPACK = -llapack -lblas

# Additional libs
ADDLIBS = -lgfortran
```

### Step 3: Build LORENE

```bash
cd $HOME_LORENE

# Build the core library
make

# Build with parallel compilation (faster)
make -j$(nproc)
```

**Expected output:**
```
Compiling C++/Lorene...
Creating library liblorene.a
Library successfully created
```

### Step 4: Build nrotdiff Code

The `nrotdiff` executable computes differentially rotating neutron star equilibria:

```bash
cd $HOME_LORENE/Codes/Nrotdiff

# Compile
make

# Verify compilation
ls -la nrotdiff
# Should show executable: -rwxr-xr-x ... nrotdiff
```

### Step 5: Test Installation

```bash
cd $HOME_LORENE/Codes/Nrotdiff

# Run with default parameters (may need EOS setup first)
./nrotdiff

# Check for output files
ls *.d  # Parameter files
```

---

## EOS Configuration

### Obtaining the DD2 Equation of State

The DD2 EOS is available from the CompOSE database:

**CompOSE Database:** [https://compose.obspm.fr](https://compose.obspm.fr)

1. Navigate to [https://compose.obspm.fr/eos/119](https://compose.obspm.fr/eos/119) (DD2 entry)
2. Download the cold neutron star EOS files
3. Required files:
   - `eos.nb` - Number density table
   - `eos.thermo` - Thermodynamic quantities table

### Installing EOS Files

```bash
# Create EOS directory
mkdir -p $HOME_LORENE/Eos/CompOSE/DD2
cd $HOME_LORENE/Eos/CompOSE/DD2

# Copy downloaded files
cp /path/to/downloaded/eos.nb .
cp /path/to/downloaded/eos.thermo .

# Verify files
head -20 eos.nb
head -20 eos.thermo
```

### EOS Parameter File (par_eos.d)

Create `par_eos.d` in your working directory:

```
# par_eos.d - Equation of State Configuration
#============================================

# EOS type (9 = CompOSE tabulated)
9

# Path to EOS files (relative to run directory)
$HOME_LORENE/Eos/CompOSE/DD2/

# EOS table format
compose

# End of par_eos.d
```

**EOS Type Codes:**
| Code | Type | Description |
|------|------|-------------|
| 1 | Polytropic | P = Kρ^Γ |
| 2 | Polytropic (strange quark) | Modified polytrope |
| 9 | CompOSE | Tabulated EOS from database |
| 17 | Multi-polytrope | Piecewise polytropic |

---

## Running nrotdiff

### Basic Execution

```bash
cd $HOME_LORENE/Codes/Nrotdiff

# Copy parameter files
cp /path/to/repo/params/parrotdiff.d .
cp /path/to/repo/params/par_eos.d .

# Run simulation
./nrotdiff

# Monitor progress
tail -f resu.d  # Output file
```

### Understanding Output

During execution, nrotdiff outputs iteration progress:

```
===============================
Iteration: 100  diff_ent = 2.34e-06
Omega_c = 11503.4 rad/s
M_grav = 2.967 M_sun
r_eq = 15.09 km
GRV2 = 1.18%  GRV3 = 0.92%
===============================
```

### Output Files

| File | Description |
|------|-------------|
| `resu.d` | Comprehensive results and diagnostics |
| `star.d` | Binary stellar model (can be reloaded) |
| `prof_*.d` | Radial/angular profiles |
| `conv.d` | Convergence history |

### Key Output Quantities

```
# From resu.d output:
Gravitational mass: M_g = 2.97 M_sun
Baryonic mass:      M_b = 3.45 M_sun
Circ. radius:       R_circ = 15.09 km
Axis ratio:         r_p/r_eq = 0.454
Central frequency:  f_c = 1823 Hz
T/|W|:              0.176
GRV2:               1.18%
GRV3:               0.92%
```

---

## Parameter Files

### parrotdiff.d Structure

The main parameter file controls the simulation:

```bash
#======================================
# parrotdiff.d - Differential Rotation
#======================================

#--------------------------
# Iteration Parameters
#--------------------------
500 mer_max           # Maximum iterations
1.e-8 precis          # Convergence threshold
10 mer_rot            # Iteration to start rotation
50. freq_ini_si [Hz]  # Initial rotation frequency
50 mer_change_omega   # Start omega ramp
100 mer_fix_omega     # End omega ramp
10 delta_mer_kep      # Keplerian search interval
0.5 thres_adapt       # Domain adaptation threshold
0.5 relax             # Main relaxation factor
500 mermax_poisson    # Poisson solver max iterations
0.6 relax_poisson     # Poisson relaxation factor
1.e-12 precis_adapt   # Adaptation precision

#--------------------------
# Grid Parameters
#--------------------------
4 nz                  # Total domains
2 nzet                # Domains inside star
1 nzadapt             # Adaptive domain
17 nt                 # Angular points (theta)
1 np                  # Azimuthal points (phi)
33 0.                 # Domain 0: nr, r_min (nucleus)
33 5.                 # Domain 1: nr, r_outer
25 12.                # Domain 2: nr, r_outer
17 25.                # Domain 3: nr, r_outer
0.05 enthalpy_boundary # Enthalpy at domain interface

#--------------------------
# Physical Parameters
#--------------------------
1 relativity          # 1 = General Relativity
0.28 ent_c            # Central enthalpy [c^2]
500.0 freq_si [Hz]    # Target frequency
2.0 rotation_type     # Uryu differential rotation
2.0 lambda_1          # Radial DR parameter
0.5 lambda_2          # Latitudinal DR parameter  
1.0 A2_initial        # Shape parameter A^2
0.5 B2_initial        # Shape parameter B^2
1.01 fact_omega       # Keplerian search factor
3.0 M_baryon_target   # Target baryonic mass [M_sun]
```

### Parameter Descriptions

#### Iteration Control

| Parameter | Description | Typical Range |
|-----------|-------------|---------------|
| `mer_max` | Maximum iterations before termination | 300-1000 |
| `precis` | Relative enthalpy change for convergence | 10⁻⁷ to 10⁻⁹ |
| `relax` | Under-relaxation factor (0=no update, 1=full) | 0.3-0.7 |
| `mer_rot` | Iteration to switch on rotation | 5-20 |

#### Grid Resolution

| Parameter | Description | Notes |
|-----------|-------------|-------|
| `nz` | Total number of spectral domains | Usually 4-6 |
| `nzet` | Domains containing stellar matter | Usually 2-3 |
| `nt` | Angular collocation points | Must be odd (17, 25, 33) |
| `nr` | Radial points per domain | Must be odd |

#### Rotation Parameters

| Parameter | Description | Type C Values |
|-----------|-------------|---------------|
| `rotation_type` | 0=uniform, 2=Uryū | 2 |
| `lambda_1` | Radial differential rotation strength | 1.5-2.5 |
| `lambda_2` | Ratio Ω_eq/Ω_c | 0.3-0.7 |
| `A2_initial` | Shape parameter | 0.5-2.0 |
| `B2_initial` | Shape parameter | 0.3-1.0 |

---

## Troubleshooting

### Common Issues

#### 1. Compilation Errors

**Problem:** `undefined reference to 'fftw_...'`
```bash
# Solution: Check FFTW paths in local_settings
pkg-config --cflags --libs fftw3
# Update FFTW_INCLUDE and FFTW_LIB accordingly
```

**Problem:** `cannot find -lgsl`
```bash
# Solution: Install GSL development files
sudo apt-get install libgsl-dev
```

#### 2. Convergence Failures

**Problem:** `diff_ent` oscillates or increases
```
# Solutions:
# 1. Reduce relaxation factor
0.3 relax          # Try lower value

# 2. Increase initial iterations before rotation
20 mer_rot         # Delay rotation start

# 3. Reduce target frequency incrementally
300.0 freq_si      # Start with lower frequency
```

**Problem:** Enthalpy goes negative
```
# Solutions:
# 1. Reduce central enthalpy
0.25 ent_c         # Try lower value

# 2. Check EOS tables for valid range
head -50 eos.thermo
```

#### 3. Large Virial Errors (GRV2, GRV3 > 5%)

**Problem:** Poor numerical accuracy
```
# Solutions:
# 1. Increase radial resolution
49 0.              # More points in nucleus
49 5.              # More points in domain 1

# 2. Increase angular resolution
25 nt              # More theta points

# 3. Adjust domain boundaries
33 0.
33 7.              # Expand inner domains
25 15.
17 30.
```

#### 4. EOS Loading Errors

**Problem:** `Cannot open EOS file`
```bash
# Check file paths
ls -la $HOME_LORENE/Eos/CompOSE/DD2/

# Verify par_eos.d path is correct
cat par_eos.d

# Use absolute path if needed
/home/user/lorene/Eos/CompOSE/DD2/
```

### Performance Tips

1. **Parallel Compilation:**
   ```bash
   make -j$(nproc)  # Use all CPU cores
   ```

2. **Memory Management:**
   - High-resolution runs (nt=33, nr=65) may need 16+ GB RAM
   - Monitor with `htop` during execution

3. **Incremental Approach:**
   - Start with coarse resolution to verify setup
   - Gradually increase resolution for production runs

---

## References

### LORENE Documentation
- [Official LORENE Documentation](https://lorene.obspm.fr/DOC/html/index.html)
- [Class Reference](https://lorene.obspm.fr/DOC/html/annotated.html)

### Key Papers
- Bonazzola, S. et al. (1998). "Numerical models of irrotational binary neutron stars in general relativity." [Phys. Rev. D 58, 104020](https://doi.org/10.1103/PhysRevD.58.104020)
- Gourgoulhon, E. et al. (1999). "Quasiequilibrium sequences of synchronized and irrotational binary neutron stars in general relativity." [A&A 349, 851](https://ui.adsabs.harvard.edu/abs/1999A%26A...349..851G)
- Nozawa, T. et al. (1998). "Construction of highly accurate models of rotating neutron stars." [A&AS 132, 431](https://doi.org/10.1051/aas:1998304)

### CompOSE Database
- [CompOSE Main Page](https://compose.obspm.fr)
- [Quick Guides](https://doi.org/10.3390/particles5030028)
- Typel, S. et al. (2015). "CompOSE CompStar online supernova equations of state." [Physics of Particles and Nuclei 46, 633](https://doi.org/10.1134/S1063779615040061)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Dec 2025 | Initial release with DD2 EOS, Type C rotation |

---

**Questions or Issues?** Open an issue on the repository or consult the [LORENE mailing list](https://lorene.obspm.fr/mailing.html).
