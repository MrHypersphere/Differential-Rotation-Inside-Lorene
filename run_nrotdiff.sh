#!/bin/bash
#======================================================
# run_nrotdiff.sh - Execute LORENE nrotdiff simulations
#
# Usage:
#   ./run_nrotdiff.sh [lambda_value]
#   ./run_nrotdiff.sh 1.5
#   ./run_nrotdiff.sh 2.0
#   ./run_nrotdiff.sh all
#======================================================

set -e  # Exit on error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PARAMS_DIR="$REPO_DIR/params"
RESULTS_DIR="$REPO_DIR/results"

# Check LORENE installation
if [ -z "$HOME_LORENE" ]; then
    echo "Error: HOME_LORENE environment variable not set"
    echo "Please set: export HOME_LORENE=/path/to/lorene"
    exit 1
fi

NROTDIFF_DIR="$HOME_LORENE/Codes/Nrotdiff"
NROTDIFF_EXE="$NROTDIFF_DIR/nrotdiff"

if [ ! -x "$NROTDIFF_EXE" ]; then
    echo "Error: nrotdiff executable not found at $NROTDIFF_EXE"
    echo "Please compile LORENE first: cd \$HOME_LORENE/Codes/Nrotdiff && make"
    exit 1
fi

# Create results directory with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RUN_DIR="$RESULTS_DIR/run_$TIMESTAMP"

#------------------------------------------------------
# Function to run a single configuration
#------------------------------------------------------
run_config() {
    local lambda1=$1
    local config_name="lambda${lambda1}"
    local param_file="$PARAMS_DIR/parrotdiff_lambda${lambda1}.d"
    
    echo "=============================================="
    echo "Running configuration: λ₁ = $lambda1"
    echo "=============================================="
    
    # Check parameter file exists
    if [ ! -f "$param_file" ]; then
        echo "Error: Parameter file not found: $param_file"
        return 1
    fi
    
    # Create output directory
    local output_dir="$RUN_DIR/$config_name"
    mkdir -p "$output_dir"
    
    # Copy parameter files
    cp "$param_file" "$output_dir/parrotdiff.d"
    cp "$PARAMS_DIR/par_eos.d" "$output_dir/"
    
    # Change to output directory and run
    cd "$output_dir"
    
    echo "Starting nrotdiff at $(date)"
    echo "Output directory: $output_dir"
    echo ""
    
    # Run nrotdiff with timing
    local start_time=$(date +%s)
    
    if "$NROTDIFF_EXE" > stdout.log 2> stderr.log; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        echo "Completed successfully in ${duration}s"
        echo ""
        
        # Extract key results
        if [ -f "resu.d" ]; then
            echo "Key Results:"
            echo "------------"
            grep -E "(Gravitational mass|Baryonic mass|radius|T/\|W\||GRV)" resu.d | head -10
        fi
    else
        echo "Error: nrotdiff failed. Check stderr.log for details."
        cat stderr.log
        return 1
    fi
    
    echo ""
    return 0
}

#------------------------------------------------------
# Function to compare results
#------------------------------------------------------
compare_results() {
    echo "=============================================="
    echo "Comparing Results"
    echo "=============================================="
    
    if [ -d "$RUN_DIR/lambda1.5" ] && [ -d "$RUN_DIR/lambda2.0" ]; then
        python3 "$SCRIPT_DIR/parse_output.py" \
            "$RUN_DIR/lambda1.5/resu.d" \
            "$RUN_DIR/lambda2.0/resu.d" \
            --compare
    else
        echo "Both configurations must be run for comparison"
    fi
}

#------------------------------------------------------
# Main execution
#------------------------------------------------------
main() {
    local lambda_arg="${1:-all}"
    
    echo "=============================================="
    echo "LORENE Type C Differential Rotation Study"
    echo "=============================================="
    echo "Date: $(date)"
    echo "LORENE: $HOME_LORENE"
    echo "Results: $RUN_DIR"
    echo ""
    
    mkdir -p "$RUN_DIR"
    
    case "$lambda_arg" in
        "1.5")
            run_config "1.5"
            ;;
        "2.0")
            run_config "2.0"
            ;;
        "all")
            echo "Running both configurations..."
            echo ""
            run_config "1.5" || true
            run_config "2.0" || true
            compare_results
            ;;
        *)
            echo "Usage: $0 [1.5|2.0|all]"
            echo ""
            echo "Options:"
            echo "  1.5  - Run λ₁ = 1.5 configuration only"
            echo "  2.0  - Run λ₁ = 2.0 configuration only"
            echo "  all  - Run both configurations and compare"
            exit 1
            ;;
    esac
    
    echo ""
    echo "=============================================="
    echo "All runs completed at $(date)"
    echo "Results saved to: $RUN_DIR"
    echo "=============================================="
}

main "$@"
