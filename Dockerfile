# syntax=docker/dockerfile-upstream:master-labs

# Base emsdk image with environment variables.
FROM emscripten/emsdk:3.1.40 AS emsdk-base
ARG EXTRA_CFLAGS
ARG EXTRA_LDFLAGS
ARG FFMPEG_ST
ARG FFMPEG_MT
ENV INSTALL_DIR=/opt
ENV FFMPEG_VERSION=n5.1.4
ENV CFLAGS="-I$INSTALL_DIR/include $CFLAGS $EXTRA_CFLAGS"
ENV CXXFLAGS="$CFLAGS"
ENV LDFLAGS="-L$INSTALL_DIR/lib $LDFLAGS $CFLAGS $EXTRA_LDFLAGS"
ENV EM_PKG_CONFIG_PATH=$EM_PKG_CONFIG_PATH:$INSTALL_DIR/lib/pkgconfig:/emsdk/upstream/emscripten/system/lib/pkgconfig
ENV EM_TOOLCHAIN_FILE=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake
ENV PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$EM_PKG_CONFIG_PATH
ENV FFMPEG_ST=$FFMPEG_ST
ENV FFMPEG_MT=$FFMPEG_MT
RUN apt-get update && \
      apt-get install -y pkg-config autoconf automake libtool ragel

# Build libogg
FROM emsdk-base AS ogg-builder
ENV OGG_BRANCH=v1.3.4
ADD https://github.com/ffmpegwasm/Ogg.git#$OGG_BRANCH /src
COPY build/ogg.sh /src/build.sh
RUN bash -x /src/build.sh

# Build libopus
FROM emsdk-base AS opus-builder
ENV OPUS_BRANCH=v1.3.1
ADD https://github.com/ffmpegwasm/opus.git#$OPUS_BRANCH /src
COPY build/opus.sh /src/build.sh
RUN bash -x /src/build.sh

# Build vorbis
FROM emsdk-base AS vorbis-builder
COPY --from=ogg-builder $INSTALL_DIR $INSTALL_DIR
ENV VORBIS_BRANCH=v1.3.3
ADD https://github.com/ffmpegwasm/vorbis.git#$VORBIS_BRANCH /src
COPY build/vorbis.sh /src/build.sh
RUN bash -x /src/build.sh

# Build ffmpeg with only necessary components
FROM emsdk-base AS ffmpeg-base
ADD https://github.com/FFmpeg/FFmpeg.git#$FFMPEG_VERSION /src
COPY --from=opus-builder $INSTALL_DIR $INSTALL_DIR
COPY --from=vorbis-builder $INSTALL_DIR $INSTALL_DIR
COPY build/ffmpeg.sh /src/build.sh
RUN bash -x /src/build.sh \
      --enable-libvorbis \
      --enable-libopus

# Build ffmpeg.wasm
FROM ffmpeg-builder AS ffmpeg-wasm-builder
COPY src/bind /src/src/bind
COPY src/fftools /src/src/fftools
COPY build/ffmpeg-wasm.sh build.sh
# Libraries to link
ENV FFMPEG_LIBS \
      -logg \
      -lvorbis
      -lvorbisenc
      -lvorbisfile
      -lopus
RUN mkdir -p /src/dist/umd && bash -x /src/build.sh \
      ${FFMPEG_LIBS} \
      -o dist/umd/ffmpeg-core.js
RUN mkdir -p /src/dist/esm && bash -x /src/build.sh \
      ${FFMPEG_LIBS} \
      -sEXPORT_ES6 \
      -o dist/esm/ffmpeg-core.js

# Export ffmpeg-core.wasm to dist/
FROM scratch AS exportor
COPY --from=ffmpeg-wasm-builder /src/dist /dist
