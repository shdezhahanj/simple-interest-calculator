#!/usr/bin/env bash
# simple-interest.sh
#
# Calculate simple interest:  Interest = Principal * Rate * Time / 100
# Usage:
#   ./simple-interest.sh -p PRINCIPAL -r RATE -t TIME
#   ./simple-interest.sh PRINCIPAL RATE TIME
# Examples:
#   ./simple-interest.sh -p 1000 -r 5 -t 2
#   ./simple-interest.sh 1000 5 2
#
# Author: Your Name
# License: Apache-2.0

set -euo pipefail

print_help() {
  cat <<'EOF'
simple-interest.sh - calculate simple interest

Usage:
  ./simple-interest.sh -p PRINCIPAL -r RATE -t TIME
  ./simple-interest.sh PRINCIPAL RATE TIME

Options:
  -p, --principal   Principal amount (e.g., 1000 or 1000.50)
  -r, --rate        Annual interest rate in percent (e.g., 5 or 4.25)
  -t, --time        Time period in years (e.g., 2 or 1.5)
  -h, --help        Display this help and exit

Examples:
  ./simple-interest.sh -p 1000 -r 5 -t 2
  ./simple-interest.sh 1000 5 2
EOF
}

# Default values
PRINCIPAL=""
RATE=""
TIME_YEARS=""

# If no args provided, show help
if [ "$#" -eq 0 ]; then
  print_help
  exit 0
fi

# Parse flags (supports long and short)
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--principal)
      PRINCIPAL="$2"; shift 2;;
    -r|--rate)
      RATE="$2"; shift 2;;
    -t|--time)
      TIME_YEARS="$2"; shift 2;;
    -h|--help)
      print_help; exit 0;;
    --) shift; break;;
    -*)
      echo "Unknown option: $1" >&2; print_help; exit 2;;
    *) # positional args
      if [ -z "$PRINCIPAL" ]; then
        PRINCIPAL="$1"
      elif [ -z "$RATE" ]; then
        RATE="$1"
      elif [ -z "$TIME_YEARS" ]; then
        TIME_YEARS="$1"
      else
        echo "Too many positional arguments." >&2
        print_help
        exit 2
      fi
      shift;;
  esac
done

# Validate inputs (non-empty, numeric, non-negative)
is_number() {
  # Accepts integers and decimals, optional leading +/-
  [[ $1 =~ ^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$ ]]
}

for varname in PRINCIPAL RATE TIME_YEARS; do
  value="${!varname}"
  if [ -z "$value" ]; then
    echo "Error: $varname is required." >&2
    print_help
    exit 2
  fi
  if ! is_number "$value"; then
    echo "Error: $varname ('$value') is not a valid number." >&2
    exit 2
  fi
  # negative check
  if awk "BEGIN{exit !($value < 0)}"; then
    echo "Error: $varname ('$value') must not be negative." >&2
    exit 2
  fi
done

# Use bc for decimal arithmetic. Format output to 2 decimal places.
# interest = principal * rate * time / 100
INTEREST=$(printf "%s\n" "scale=10; ($PRINCIPAL) * ($RATE) * ($TIME_YEARS) / 100" | bc -l)
TOTAL=$(printf "%s\n" "scale=10; ($PRINCIPAL) + ($INTEREST)" | bc -l)

# Round to 2 decimal places for display
round2() {
  printf "%.2f" "$(printf "%s\n" "scale=10; $1" | bc -l)"
}

echo "Principal: $(round2 "$PRINCIPAL")"
echo "Rate (%):  $(round2 "$RATE")"
echo "Time (y):  $(round2 "$TIME_YEARS")"
echo "Simple Interest: $(round2 "$INTEREST")"
echo "Total Amount:    $(round2 "$TOTAL")"

exit 0
