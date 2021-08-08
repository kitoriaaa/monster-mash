FROM ubuntu:20.04

RUN apt update && \
    apt install -y tzdata
RUN apt install -y build-essential \
    cmake \
    libsdl2-dev \
    wget \
    unzip \
    git \
    python3

COPY third_party /app/third_party
COPY src /app/src
COPY data/shaders /app/data/shaders

WORKDIR /app
RUN wget http://www.netlib.org/voronoi/triangle.zip && unzip triangle.zip -d third_party/triangle

RUN git clone https://github.com/emscripten-core/emsdk.git && \
    cd emsdk && \
    git pull && \
    ./emsdk install latest && \
    ./emsdk activate latest

WORKDIR /app/build/Release

RUN /bin/bash -c "source "/app/emsdk/emsdk_env.sh" && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_C_COMPILER=emcc \
          -DCMAKE_CXX_COMPILER=em++ \
          ../../src \
    && make"

CMD [ "python3", "-m", "http.server", "8080"]
