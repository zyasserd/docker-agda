# [ Variables ]
ARG GHC_VER



# [ Builder Image ]
FROM haskell:${GHC_VER}-slim AS builder

# [ More Variables ]
ARG AGDA_VER
ARG AGDA_STDLIB_VER
ARG AGDA_CUBICAL_VER

# Install Agda
RUN cabal update
RUN cabal install Agda-${AGDA_VER}
RUN cabal clean

# Install libraries [1: cubical]
RUN git clone --depth 1 -b "v${AGDA_CUBICAL_VER}" https://github.com/agda/cubical.git       /root/.agda/cubical
#!! if 'compiled' => 1
# RUN cd /root/.agda/cubical && make

# Install libraries [2: stdlib]
RUN git clone --depth 1 -b "v${AGDA_STDLIB_VER}"  https://github.com/agda/agda-stdlib.git   /root/.agda/stdlib
#!! if 'compiled' => 2 3
# prerequisite for stdlib installation
# RUN cd /tmp && git clone https://github.com/agda/fix-whitespace --depth 1 && cd fix-whitespace/ && cabal install
# RUN cd /root/.agda/stdlib && make

# Install libraries [...]
# LATER : do you want to import other libraries as well: 1lab, unimath, agda-categories, PLFA,...

# register the libraries
RUN echo "/root/.agda/stdlib/standard-library.agda-lib" >> /root/.agda/libraries && \
    echo "/root/.agda/cubical/cubical.agda-lib"         >> /root/.agda/libraries && \
    echo "standard-library" >> /root/.agda/defaults && \
    echo "cubical"          >> /root/.agda/defaults

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

