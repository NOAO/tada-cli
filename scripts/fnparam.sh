#!/bin/bash
# Usage:
#   find `pwd` -name "*.fz" -exec fnparam.sh {} \;
#

fname=$1 # abolute path

echo "params: {filename: $fname}" > $fname.yaml 
