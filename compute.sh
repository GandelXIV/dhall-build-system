#!/bin/bash

# This script returns processed dhall code given a file

set -xe

if [ $# -eq 1 ]; then 
    dhall resolve --file $1 | dhall normalize 

else
    echo "Invalid Arguments!"

fi
