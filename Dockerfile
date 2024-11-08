FROM public.ecr.aws/docker/library/debian:bookworm-slim

WORKDIR /

RUN apt update && \
    apt upgrade -y && \
    apt install -y git cmake ninja-build wget lsb-release software-properties-common gnupg

RUN wget https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh
RUN ./llvm.sh 18
RUN rm /llvm.sh

RUN git clone https://github.com/michael-redpanda/debug-pollfd /debug-pollfd

WORKDIR /debug-pollfd

RUN git submodule update --init --recursive
RUN ./seastar/install-dependencies.sh
RUN CC=clang-18 CXX=clang++-18 cmake -Bbuild -S. -GNinja -DCMAKE_BUILD_TYPE=Release
RUN ninja -C build
RUN mv build/main /main

WORKDIR /

RUN rm -rf /debug-pollfd

ENTRYPOINT ["/main"]
