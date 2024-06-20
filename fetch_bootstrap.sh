#!/bin/sh
RUST_VERSION=1.79.0

mkdir -p /tmp/${RUST_VERSION} /usr/ports/distfiles/rust/rust-bin/${RUST_VERSION}
rsync poudre:"/usr/local/poudriere/data/packages/133amd64-rust-rust/All/*rust-bootstrap*" /tmp/${RUST_VERSION}
cd /tmp/${RUST_VERSION}
cat *.pkg | tar --ignore-zeros -xf -
mv usr/local/rust-bootstrap/*/*.xz /usr/ports/distfiles/rust/rust-bin/${RUST_VERSION}

fetch -o /usr/ports/distfiles/rust/rust-bin/${RUST_VERSION} https://dev-static.rust-lang.org/dist/rust-std-${RUST_VERSION}-wasm32-unknown-unknown.tar.xz
