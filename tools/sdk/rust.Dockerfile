FROM wifx/lorix-os-sdk

RUN apt install curl libssl-dev -y

# Install cargo/rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
RUN source $HOME/.cargo/env

RUN rustup target add armv7-unknown-linux-gnueabihf
