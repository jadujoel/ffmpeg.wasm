#!/bin/bash

set -euo pipefail

CONF_FLAGS=(
  --target-os=none              # Disable target-specific configs
  --arch=x86_32                 # Use x86_32 architecture
  --enable-cross-compile        # Use cross-compile configs
  --disable-asm                 # Disable assembly optimizations
  --disable-stripping           # Disable stripping (won't work with Emscripten)
  --disable-programs            # Disable building ffmpeg, ffprobe, and ffplay
  --disable-doc                 # Disable building documentation
  --disable-debug               # Disable debug mode
  --disable-runtime-cpudetect   # Disable CPU detection
  --disable-autodetect          # Disable environment autodetection

  # Disable all components by default
  # --disable-everything

  # # Enable only the necessary components
  # --enable-decoder=opus         # Enable Opus decoder
  # --enable-demuxer=ogg          # Enable Ogg demuxer
  # --enable-muxer=wav            # Enable WAV muxer
  # --enable-encoder=pcm_s16le    # Enable PCM signed 16-bit little-endian encoder
  # --enable-parser=opus          # Enable Opus parser
  # --enable-protocol=file        # Enable file protocol

  # Assign toolchains and extra flags
  --nm=emnm
  --ar=emar
  --ranlib=emranlib
  --cc=emcc
  --cxx=em++
  --objcc=emcc
  --dep-cc=emcc
  --extra-cflags="$CFLAGS"
  --extra-cxxflags="$CXXFLAGS"

  # Disable threading if FFMPEG_ST is defined
  ${FFMPEG_ST:+ --disable-pthreads --disable-w32threads --disable-os2threads}
)

emconfigure ./configure "${CONF_FLAGS[@]}" "$@"
emmake make -j
