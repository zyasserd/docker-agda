#!/bin/bash

GHC_VER=9.8.1
AGDA_VER=2.6.4.3
AGDA_STDLIB_VER=2.0
AGDA_CUBICAL_VER=0.7

args=(
    ""
    "compiled"
    "compiled haskell"
)

for arg in "${args[@]}"; do
    tag=$(perl -e 'unshift @ARGV, ""; print join("-", @ARGV)' $arg)

    ./commentor.py dockerfile $arg \
        | docker build \
            --build-arg GHC_VER=$GHC_VER \
            --build-arg AGDA_VER=$AGDA_VER \
            --build-arg AGDA_STDLIB_VER=$AGDA_STDLIB_VER \
            --build-arg AGDA_CUBICAL_VER=$AGDA_CUBICAL_VER \
            --tag "zyasserd/agda:latest$tag" \
            --tag "zyasserd/agda:$AGDA_VER$tag" \
            -
done
