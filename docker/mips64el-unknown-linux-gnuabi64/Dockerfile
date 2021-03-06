FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    cmake \
    gcc \
    libc6-dev \
    make \
    pkg-config

COPY openssl.sh qemu.sh /
RUN apt-get install -y --no-install-recommends \
    g++-mips64el-linux-gnuabi64 \
    libc6-dev-mips64el-cross && \
    bash /openssl.sh 1.0.2j linux64-mips64 mips64el-linux-gnuabi64- && \
    bash /qemu.sh 2.8.0 mips64el

RUN apt-get install -y --no-install-recommends \
    curl && \
    curl -LSfs http://japaric.github.io/trust/install.sh | \
    sh -s -- --git japaric/xargo --tag v0.3.5 --target x86_64-unknown-linux-gnu --to /usr/bin && \
    apt-get purge --auto-remove -y curl

ENV CARGO_TARGET_MIPS64EL_UNKNOWN_LINUX_GNUABI64_LINKER=mips64el-linux-gnuabi64-gcc \
    CC_mips64el_unknown_linux_gnuabi64=mips64el-linux-gnuabi64-gcc \
    CXX_mips64el_unknown_linux_gnuabi64=mips64el-linux-gnuabi64-g++ \
    OPENSSL_DIR=/openssl \
    OPENSSL_INCLUDE_DIR=/openssl/include \
    OPENSSL_LIB_DIR=/openssl/lib \
    QEMU_LD_PREFIX=/usr/mips64el-linux-gnuabi64 \
    RUST_TEST_THREADS=1
