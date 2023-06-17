#!/usr/bin/env bash

function install-colab-julia {
    set -e

    JULIA_VERSION="$1" # any version ≥ 0.7.0
    JULIA_NUM_THREADS="$2"

    if [ -z `which julia` ]; then
        # Install Julia
        JULIA_VER=`cut -d '.' -f -2 <<< "$JULIA_VERSION"`
        JULIA_URL="https://julialang-s3.julialang.org/bin/linux/x64/$JULIA_VER/julia-$JULIA_VERSION-linux-x86_64.tar.gz"
        
        # -nv means "not verbose"
        wget -nv $JULIA_URL -O /tmp/julia.tar.gz
        
        # Deflate Julia
        tar -x -f /tmp/julia.tar.gz -C /usr/local --strip-components 1
        
        # Remove Tarball
        rm /tmp/julia.tar.gz

        # Install kernel and rename it to "julia"
        julia -e '
        import Pkg; Pkg.activate(); Pkg.add("IJulia");
        
        using IJulia;

        IJulia.installkernel(
            "julia",
            env = Dict("JULIA_NUM_THREADS"=>"'"$JULIA_NUM_THREADS"'")
        )'

        KERNEL_PATH=`julia -e "using IJulia; print(IJulia.kerneldir())"`
        KERNEL_NAME=`ls -d "$KERNEL_PATH"/julia*`
        mv -f $KERNEL_NAME "$KERNEL_PATH"/julia

        echo "Successfully installed `julia -v`!"
        echo "Please reload this page (press Ctrl+R, ⌘+R, or the F5 key)."
    fi

    return 0;
}

if [[ $# -eq 0 ]]; then
    install-colab-julia "1.9.1" 2
elif [[ $# -eq 1 ]]; then
    install-colab-julia "$1" 2
else
    install-colab-julia "$1" "$2"
fi
