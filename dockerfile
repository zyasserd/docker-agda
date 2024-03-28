# [ Variables ]
ARG GHC_VER=9.8.1
ARG AGDA_VER=2.6.4.3
ARG AGDA_STDLIB_VER=2.0
ARG AGDA_CUBICAL_VER=0.7



# [ Builder Image ]
FROM haskell:${GHC_VER}-slim AS builder

# Variables Re-introduction
ARG AGDA_VER
ARG AGDA_STDLIB_VER
ARG AGDA_CUBICAL_VER

# Install Agda
RUN cabal update
RUN cabal install Agda-${AGDA_VER}
RUN cabal clean

# Install libraries
#? LATER : do you want to import other libraries as well: 1lab, unimath, agda-categories, PLFA,...
RUN git clone --depth 1 -b "v${AGDA_STDLIB_VER}"  https://github.com/agda/agda-stdlib.git   /root/.agda/stdlib
RUN git clone --depth 1 -b "v${AGDA_CUBICAL_VER}" https://github.com/agda/cubical.git       /root/.agda/cubical

# register the libraries
RUN echo "/root/.agda/stdlib/standard-library.agda-lib" >> /root/.agda/libraries && \
    echo "/root/.agda/cubical/cubical.agda-lib"         >> /root/.agda/libraries && \
    echo "standard-library" >> /root/.agda/defaults && \
    echo "cubical"          >> /root/.agda/defaults

# Compile all agda files (it takes a lot of time, around ~2:30 hrs)
#!! if 'compiled' => 1
# RUN for i in `find /root/.agda/ -name "*.agda" -type f`; do agda $i || continue; done

# Removing All Cabal Libraries but Agda
#!! if 'haskell' => #1 #2
RUN cd /root/.local/state/cabal/store/*/ && \
    rm -rf $(ls -A | grep -v "^Agda")




# [ Actual Image ]
#!! if 'haskell' => #1 2
FROM debian:buster-slim
# FROM haskell:${GHC_VER}-slim

# Add in ENV so that agda works 
ENV PATH="$PATH:/root/.local/bin"

# Copy Agda Binaries and Executables
#   - Cabal packages are installed in
#           /root/.local/state/cabal/store
#   - Cabal copies the package executables in 
#           /root/.local/bin
COPY --from=builder /root/.local/ /root/.local/

# Copy Agda Libraries
COPY --from=builder /root/.agda /root/.agda

