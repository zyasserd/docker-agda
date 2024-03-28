#!/bin/bash

# For handling arguments, I used code in 
# https://medium.com/@wujido20/handling-flags-in-bash-scripts-4b06b4d0ed04

# Default variable values
multi_platform_mode=false
push_mode=false

# Function to display script usage
usage() {
 echo "Usage: $0 [OPTIONS]"
 echo "Options:"
 echo " -h, --help              Display this help message"
 echo " -m, --multi-platform    Compile both linux/arm64/v8,linux/amd64 using buildx."
 echo " -p, --push              Push to Docker Hub."
}

has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}

extract_argument() {
  echo "${2:-${1#*=}}"
}

# Function to handle options and arguments
handle_options() {
  while [ $# -gt 0 ]; do
    case $1 in
      -h | --help)
        usage
        exit 0
        ;;
      -m | --multi-platform)
        multi_platform_mode=true
        ;;
      -p | --push)
        push_mode=true
        ;;
      *)
        echo "Invalid option: $1" >&2
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# Main script execution
handle_options "$@"





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

    if [ "$multi_platform_mode" = true ]; then
        ./commentor.py dockerfile $arg \
            | docker buildx build \
                --platform linux/arm64/v8,linux/amd64
                --build-arg GHC_VER=$GHC_VER \
                --build-arg AGDA_VER=$AGDA_VER \
                --build-arg AGDA_STDLIB_VER=$AGDA_STDLIB_VER \
                --build-arg AGDA_CUBICAL_VER=$AGDA_CUBICAL_VER \
                --tag "zyasserd/agda:latest$tag" \
                --tag "zyasserd/agda:$AGDA_VER$tag" \
                -
    else # [ single-platform ]
        ./commentor.py dockerfile $arg \
            | docker build \
                --build-arg GHC_VER=$GHC_VER \
                --build-arg AGDA_VER=$AGDA_VER \
                --build-arg AGDA_STDLIB_VER=$AGDA_STDLIB_VER \
                --build-arg AGDA_CUBICAL_VER=$AGDA_CUBICAL_VER \
                --tag "zyasserd/agda:latest$tag" \
                --tag "zyasserd/agda:$AGDA_VER$tag" \
                -
    fi


    if [ "$push_mode" = true ]; then
        docker image push "zyasserd/agda:latest$tag"
        docker image push "zyasserd/agda:$AGDA_VER$tag"
    fi

done
