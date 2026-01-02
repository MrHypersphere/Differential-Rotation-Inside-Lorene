# Maximum Mass of Type C Differentially Rotating Neutron Stars

[![LORENE](https://img.shields.io/badge/Framework-LORENE-blue)](https://lorene.obspm.fr)
[![EOS](https://img.shields.io/badge/EOS-DD2%20(CompOSE)-green)](https://compose.obspm.fr)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Numerical investigation of maximum gravitational mass achievable by differentially rotating neutron stars using the Uryū Type C rotation law and DD2 equation of state. This repository contains configuration files, analysis scripts, and documentation for reproducing the results from the Physics 4900 research project.

## Key Results

| Configuration | λ₁ | Gravitational Mass | Mass Enhancement | T/\|W\| |
|---------------|-----|-------------------|------------------|---------|
| Type C-A | 1.5 | 2.94 M☉ | +21.5% | 0.187 |
| Type C-B | 2.0 | 2.97 ± 0.01 M☉ | +22.7% | 0.176 |

Both configurations exceed the TOV limit (M_TOV = 2.42 M☉) for the DD2 EOS while remaining below the dynamical bar-mode instability threshold (T/|W| ≈ 0.27).

## Physical Background

### Differential Rotation in Neutron Star Mergers

When binary neutron stars merge, the resulting remnant inherits substantial angular momentum from the orbital motion. The violent merger dynamics generate strongly differential rotation profiles, where inner regions rotate more rapidly than outer layers. If the total mass exceeds the maximum for uniform rotation but remains below the differentially rotating maximum, a hypermassive neutron star (HMNS) forms.

### Type C Uryū Rotation Law

The Type C differential rotation law produces an off-center peak in angular velocity, characterized by:

```
Ω(F) = Ωc × [1 + (F / B²Ωc)] / [1 + (F / A²Ωc)]^λ₁
```

Where:
- `Ωc`: Central angular velocity
- `λ₁`: Controls radial differential rotation strength (1.5–2.0)
- `λ₂ = Ωeq/Ωc`: Controls latitudinal differential rotation (0.5)
- `A²`, `B²`: Dimensionless shape parameters

This law yields quasi-toroidal density distributions where the maximum angular velocity occurs off-center, enabling configurations that avoid mass-shedding limits.

## Repository Structure

```
neutron-star-type-c-dr/
├── README.md                    # This file
├── docs/
│   └── LORENE_SETUP.md          # Detailed LORENE installation guide
├── params/
│   ├── par_eos.d                # Equation of state configuration
│   ├── parrotdiff_lambda1.5.d   # Parameters for λ₁ = 1.5
│   └── parrotdiff_lambda2.0.d   # Parameters for λ₁ = 2.0
├── eos/
│   └── README.md                # Instructions for obtaining DD2 EOS
├── scripts/
│   ├── run_nrotdiff.sh          # Execution script
│   └── parse_output.py          # Output parsing and analysis
├── analysis/
│   └── plotting.py              # Visualization scripts
└── results/
    └── README.md                # Results documentation
```

## Quick Start

### Prerequisites

- Linux system (Ubuntu 22.04+ recommended)
- C++ compiler with C++11 support
- FFTW3 library
- GSL (GNU Scientific Library)
- PGPLOT (optional, for visualization)
- Python 3.8+ (for analysis scripts)

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/neutron-star-type-c-dr.git
   cd neutron-star-type-c-dr
   ```

2. **Install LORENE:** Follow the detailed instructions in [`docs/LORENE_SETUP.md`](docs/LORENE_SETUP.md)

3. **Obtain the DD2 EOS:** Download from [CompOSE database](https://compose.obspm.fr/eos/119)

4. **Run a configuration:**
   ```bash
   cd $HOME_LORENE/Codes/Nrotdiff
   cp /path/to/this/repo/params/parrotdiff_lambda2.0.d parrotdiff.d
   ./nrotdiff
   ```

## Equation of State

This work uses the **DD2 (Density-Dependent)** relativistic mean field equation of state:

| Property | Value |
|----------|-------|
| Model Type | Relativistic Mean Field |
| Coupling | Density-dependent |
| Incompressibility K | ~243 MeV |
| Symmetry Energy Slope L | ~55 MeV |
| TOV Maximum Mass | 2.42 M☉ |
| Classification | Moderately stiff |

**Source:** GPPVA implementation from [CompOSE](https://compose.obspm.fr)

Required files:
- `eos.nb` - Number density table
- `eos.thermo` - Thermodynamic quantities

## Computational Parameters

### Spectral Grid Configuration

```
4   nz        # Total domains
2   nzet      # Domains inside star
17  nt        # Angular points (θ)
1   np        # Azimuthal points (φ) - axisymmetry
33  nr        # Radial points per domain
```

### Physical Parameters

| Parameter | Type C-A | Type C-B |
|-----------|----------|----------|
| Central enthalpy Hc | 0.28 c² | 0.28 c² |
| Target frequency | 500 Hz | 500 Hz |
| λ₁ | 1.5 | 2.0 |
| λ₂ | 0.5 | 0.5 |
| A² initial | 1.0 | 1.0 |
| B² initial | 0.5 | 0.5 |

### Convergence Criteria

- Maximum iterations: 500
- Precision threshold: 10⁻⁸ (relative enthalpy change)
- Relaxation factor: 0.5
- Virial error targets: GRV2 < 2%, GRV3 < 2%

## Results Analysis

### Output Quantities

The `nrotdiff` code produces:
- **Mg**: Gravitational (ADM) mass
- **Mb**: Baryonic mass
- **Rcirc**: Circumferential equatorial radius
- **rp/req**: Polar-to-equatorial axis ratio
- **fc**, **feq**: Central and equatorial rotation frequencies
- **T/|W|**: Kinetic-to-potential energy ratio
- **GRV2**, **GRV3**: Virial error indicators

### Stability Regimes

| T/|W| Range | Stability |
|-------------|-----------|
| < 0.14 | Stable |
| 0.14 – 0.27 | Secularly unstable (GW-driven) |
| > 0.27 | Dynamically unstable (bar-mode) |

Both configurations lie in the secularly unstable regime, appropriate for HMNS remnants that evolve on gravitational wave emission timescales.

## Physical Interpretation

The quasi-toroidal structure characteristic of Type C rotation produces:

1. **Off-center density maxima**: The densest material forms a ring rather than a central core
2. **Enhanced centrifugal support**: Off-center angular momentum distribution provides additional support against collapse
3. **Reduced mass-shedding risk**: Unlike uniform rotation, Type C profiles don't terminate at a Keplerian limit

The 22-23% mass enhancement above TOV is consistent with realistic EOS predictions, though lower than the 50-70% theoretical maximum for idealized configurations.

## References

Key publications:

1. Uryū, K. et al. (2017). "New code for equilibriums and quasiequilibrium initial data of compact objects. III." [Phys. Rev. D 96, 103011](https://doi.org/10.1103/PhysRevD.96.103011)

2. Iosif, P. & Stergioulas, N. (2021). "Equilibrium sequences of differentially rotating stars with post-merger-like rotational profiles." [MNRAS 503, 850](https://doi.org/10.1093/mnras/stab392)

3. Ansorg, M., Gondek-Rosińska, D. & Villain, L. (2009). "On the solution space of differentially rotating neutron stars in general relativity." [MNRAS 396, 2359](https://doi.org/10.1111/j.1365-2966.2009.14904.x)

4. Hempel, M. & Schaffner-Bielich, J. (2010). "A Statistical Model for a Complete Supernova Equation of State." [Nucl. Phys. A 837, 210](https://doi.org/10.1016/j.nuclphysa.2010.02.010)

## Citation

If you use this work, please cite:

```bibtex
@misc{barnett2025typeC,
  author = {Barnett, Brian},
  title = {Maximum Mass of Type C Differentially Rotating Neutron Stars},
  year = {2025},
  institution = {Georgia State University},
  note = {Physics 4900 Research Report}
}
```

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- Professor Talawinder Singh (Research supervision)
- Professor Yang-Ting Chein (Research class instruction)
- LORENE development team at Observatoire de Paris
- CompOSE database maintainers

---

**Note:** This repository accompanies the Physics 4900 research report "Maximum Mass of Type C Differentially Rotating Neutron Stars" (December 2025).
