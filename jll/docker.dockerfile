FROM debian:latest

RUN apt-get update \
    && apt-get install -y \
        curl	\
		sudo 	\
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for Julia version and installation path
ENV JULIA_VERSION=1.8.0
ENV JULIA_DIR=/workspace/julia

# Download and install Julia
RUN curl -sSL "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" -o julia.tar.gz \
    && mkdir -p $JULIA_DIR \
    && tar -xzf julia.tar.gz -C $JULIA_DIR --strip-components 1 \
    && rm julia.tar.gz

# Add Julia to the PATH
ENV PATH=$JULIA_DIR/bin:$PATH

# Run Julia once to precompile base libraries
RUN julia -e 'using Pkg; Pkg.add("BinaryBuilder"); Pkg.precompile()'

# Set the working directory for the container
WORKDIR /workspace

# Default command when container starts
CMD ["julia"]