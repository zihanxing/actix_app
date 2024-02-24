# Use a Rust official image
FROM rust:1.63 as builder

# Create a new empty shell project
RUN USER=root cargo new --bin actix_app
WORKDIR /actix_app

# Copy our manifests
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# Build only the dependencies to cache them
RUN cargo build --release
RUN rm src/*.rs

# Now that the dependency is built, copy your source code
COPY ./src ./src

# Build for release.
RUN rm ./target/release/deps/actix_web_app*
RUN cargo build --release

# Final base
FROM debian:buster-slim

# Copy the build artifact from the build stage
COPY --from=builder /actix_app/target/release/actix_app .

# Set the startup command to run your binary
CMD ["./actix_app"]
