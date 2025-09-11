#!/bin/bash

echo "Setting up Tilt for $1"

(cd tanka && jb install)

(cd "tanka/environments/$1" && tk tool charts vendor)

mkdir -p .tilt && touch ".tilt/$1.yaml"
