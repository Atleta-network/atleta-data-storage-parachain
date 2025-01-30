# Stage 1: build application binary
FROM rust:1.84.0 AS builder

# Working directory
WORKDIR /app

# Copy application files
COPY . /app

# Install dependencies
RUN apt-get update && apt-get install protobuf-compiler libclang-dev libssl-dev -y

# Setup Rust toolchain
RUN rustup target add wasm32-unknown-unknown
RUN rustup component add rustfmt clippy rust-src

# Fetch
RUN cargo fetch

# Build
RUN cargo build --locked --release

# Stage 2: use small image as a "base" image
FROM ubuntu:24.10

# Working directory
WORKDIR /app

# Copy built binary file
COPY --from=builder /app/target/release/lib* /app/target/release/data-storage-node /app/bin/

# Expose default ports (P2P, WebSocket, RPC, Prometheus)
EXPOSE 30333 9933 9944 9615

# Specify entrypoint
ENTRYPOINT ["/app/bin/data-storage-node"]
