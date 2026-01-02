#!/usr/bin/env python3
"""
parse_output.py - Parse LORENE nrotdiff output files

Extracts key physical quantities from LORENE output and formats
them for analysis of differentially rotating neutron star models.

Usage:
    python parse_output.py resu.d
    python parse_output.py resu.d --json
    python parse_output.py resu.d --latex
"""

import re
import argparse
import json
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import Optional


@dataclass
class NeutronStarModel:
    """Container for neutron star equilibrium model quantities."""
    
    # Identification
    filename: str = ""
    eos_name: str = ""
    rotation_type: str = ""
    
    # Mass quantities [M_sun]
    M_grav: float = 0.0          # Gravitational (ADM) mass
    M_bary: float = 0.0          # Baryonic mass
    M_binding: float = 0.0       # Binding energy = M_b - M_g
    
    # Geometric quantities [km]
    R_circ: float = 0.0          # Circumferential equatorial radius
    R_polar: float = 0.0         # Polar radius
    axis_ratio: float = 0.0      # r_p / r_eq
    
    # Rotation quantities [Hz, rad/s]
    f_central: float = 0.0       # Central rotation frequency
    f_equatorial: float = 0.0    # Equatorial surface frequency
    f_max: float = 0.0           # Maximum rotation frequency
    Omega_c: float = 0.0         # Central angular velocity
    Omega_eq: float = 0.0        # Equatorial angular velocity
    
    # Angular momentum
    J: float = 0.0               # Total angular momentum [GM_sun^2/c]
    j_spin: float = 0.0          # Dimensionless spin parameter cJ/(GM^2)
    
    # Stability indicators
    T_W: float = 0.0             # T/|W| ratio
    
    # Thermodynamic quantities
    H_central: float = 0.0       # Central enthalpy [c^2]
    rho_central: float = 0.0     # Central baryon density [fm^-3]
    P_central: float = 0.0       # Central pressure [MeV/fm^3]
    
    # Differential rotation parameters
    lambda_1: float = 0.0
    lambda_2: float = 0.0
    A2: float = 0.0
    B2: float = 0.0
    
    # Virial errors [%]
    GRV2: float = 0.0
    GRV3: float = 0.0
    
    # Reference values
    M_TOV: float = 0.0           # TOV mass for this EOS
    mass_enhancement: float = 0.0  # M_g / M_TOV - 1


def parse_lorene_output(filepath: str) -> NeutronStarModel:
    """
    Parse LORENE resu.d output file and extract quantities.
    
    Args:
        filepath: Path to resu.d file
        
    Returns:
        NeutronStarModel with extracted quantities
    """
    model = NeutronStarModel(filename=filepath)
    
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Define regex patterns for common LORENE output formats
    patterns = {
        'M_grav': r'Gravitational mass.*?:\s*([\d.]+)\s*M_?(?:sun|sol|⊙)',
        'M_bary': r'Baryonic mass.*?:\s*([\d.]+)\s*M_?(?:sun|sol|⊙)',
        'R_circ': r'(?:Circumferential|Equatorial).*?radius.*?:\s*([\d.]+)\s*km',
        'axis_ratio': r'(?:Axis ratio|r_p/r_eq).*?:\s*([\d.]+)',
        'f_central': r'Central.*?frequency.*?:\s*([\d.]+)\s*Hz',
        'f_equatorial': r'Equatorial.*?frequency.*?:\s*([\d.]+)\s*Hz',
        'T_W': r'T/\|?W\|?.*?:\s*([\d.]+)',
        'GRV2': r'GRV2.*?:\s*([\d.]+)\s*%?',
        'GRV3': r'GRV3.*?:\s*([\d.]+)\s*%?',
        'H_central': r'Central.*?enthalpy.*?:\s*([\d.]+)',
        'Omega_c': r'Omega_?c.*?:\s*([\d.]+)',
        'J': r'Angular momentum.*?:\s*([\d.]+)',
        'lambda_1': r'lambda_?1.*?:\s*([\d.]+)',
        'lambda_2': r'lambda_?2.*?:\s*([\d.]+)',
    }
    
    for attr, pattern in patterns.items():
        match = re.search(pattern, content, re.IGNORECASE)
        if match:
            setattr(model, attr, float(match.group(1)))
    
    # Calculate derived quantities
    if model.M_grav > 0 and model.M_bary > 0:
        model.M_binding = model.M_bary - model.M_grav
    
    if model.R_circ > 0 and model.axis_ratio > 0:
        model.R_polar = model.R_circ * model.axis_ratio
    
    return model


def format_table(model: NeutronStarModel) -> str:
    """Format model as ASCII table."""
    lines = [
        "=" * 60,
        f"LORENE Neutron Star Model: {model.filename}",
        "=" * 60,
        "",
        "MASS QUANTITIES",
        "-" * 40,
        f"  Gravitational mass:  {model.M_grav:.4f} M_sun",
        f"  Baryonic mass:       {model.M_bary:.4f} M_sun",
        f"  Binding energy:      {model.M_binding:.4f} M_sun",
        "",
        "GEOMETRY",
        "-" * 40,
        f"  Equatorial radius:   {model.R_circ:.2f} km",
        f"  Polar radius:        {model.R_polar:.2f} km",
        f"  Axis ratio (r_p/r_eq): {model.axis_ratio:.3f}",
        "",
        "ROTATION",
        "-" * 40,
        f"  Central frequency:   {model.f_central:.1f} Hz",
        f"  Equatorial freq.:    {model.f_equatorial:.1f} Hz",
        f"  λ₁:                  {model.lambda_1:.2f}",
        f"  λ₂:                  {model.lambda_2:.2f}",
        "",
        "STABILITY",
        "-" * 40,
        f"  T/|W|:               {model.T_W:.4f}",
        f"  GRV2:                {model.GRV2:.2f}%",
        f"  GRV3:                {model.GRV3:.2f}%",
        "",
        "=" * 60,
    ]
    return "\n".join(lines)


def format_latex(model: NeutronStarModel) -> str:
    """Format model as LaTeX table row."""
    return (
        f"{model.lambda_1:.1f} & "
        f"{model.M_grav:.2f} & "
        f"{model.M_bary:.2f} & "
        f"{model.R_circ:.2f} & "
        f"{model.axis_ratio:.3f} & "
        f"{model.f_central:.0f} & "
        f"{model.T_W:.3f} & "
        f"{model.GRV2:.2f} \\\\"
    )


def compare_models(model1: NeutronStarModel, model2: NeutronStarModel) -> str:
    """Generate comparison between two models."""
    lines = [
        "=" * 70,
        "MODEL COMPARISON",
        "=" * 70,
        "",
        f"{'Property':<25} {'Model 1':>15} {'Model 2':>15} {'Diff':>12}",
        "-" * 70,
    ]
    
    comparisons = [
        ('λ₁', model1.lambda_1, model2.lambda_1),
        ('M_grav [M_sun]', model1.M_grav, model2.M_grav),
        ('M_bary [M_sun]', model1.M_bary, model2.M_bary),
        ('R_circ [km]', model1.R_circ, model2.R_circ),
        ('Axis ratio', model1.axis_ratio, model2.axis_ratio),
        ('f_c [Hz]', model1.f_central, model2.f_central),
        ('T/|W|', model1.T_W, model2.T_W),
        ('GRV2 [%]', model1.GRV2, model2.GRV2),
    ]
    
    for name, v1, v2 in comparisons:
        diff = v2 - v1
        pct = 100 * diff / v1 if v1 != 0 else 0
        lines.append(f"{name:<25} {v1:>15.4f} {v2:>15.4f} {pct:>+10.2f}%")
    
    lines.append("=" * 70)
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Parse LORENE nrotdiff output files"
    )
    parser.add_argument(
        "files",
        nargs="+",
        help="Path to resu.d file(s)"
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output as JSON"
    )
    parser.add_argument(
        "--latex",
        action="store_true",
        help="Output as LaTeX table row"
    )
    parser.add_argument(
        "--compare",
        action="store_true",
        help="Compare multiple models"
    )
    parser.add_argument(
        "-o", "--output",
        help="Output file path"
    )
    
    args = parser.parse_args()
    
    models = []
    for filepath in args.files:
        if Path(filepath).exists():
            model = parse_lorene_output(filepath)
            models.append(model)
        else:
            print(f"Warning: File not found: {filepath}")
    
    if not models:
        print("No valid files found.")
        return
    
    # Generate output
    if args.json:
        output = json.dumps([asdict(m) for m in models], indent=2)
    elif args.latex:
        output = "\n".join(format_latex(m) for m in models)
    elif args.compare and len(models) >= 2:
        output = compare_models(models[0], models[1])
    else:
        output = "\n\n".join(format_table(m) for m in models)
    
    # Write or print
    if args.output:
        with open(args.output, 'w') as f:
            f.write(output)
        print(f"Output written to {args.output}")
    else:
        print(output)


if __name__ == "__main__":
    main()
