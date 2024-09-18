#!/bin/bash

set -euo pipefail

CONF_FLAGS=(
  --target-os=none              # disable target specific configs
  --arch=x86_32                 # use x86_32 arch
  --enable-cross-compile        # use cross compile configs
  --disable-asm                 # disable asm
  --disable-stripping           # disable stripping as it won't work
  --disable-programs            # disable ffmpeg, ffprobe and ffplay build
  --disable-doc                 # disable doc build
  --disable-debug               # disable debug mode
  --disable-runtime-cpudetect   # disable cpu detection
  --disable-autodetect          # disable env auto detect

  # make smaller
  --disable-avdevice
  ## --disable-swresample
  ## --disable-avcodec
  ## --disable-avformat
  --disable-swscale-alpha
  ## --disable-swscale
  --disable-postproc
  ## --disable-avfilter
  --disable-network
  # --disable-dct
  # --disable-dwt
  --disable-error-resilience
  # --disable-lsp
  # --disable-mdct
  # --disable-rdft
  # --disable-fft
  # --disable-faan
  --disable-pixelutils

  --disable-alsa
  --disable-appkit
  --disable-avfoundation
  --disable-bzlib
  --disable-coreimage
  --disable-iconv
  --disable-lzma
  --disable-metal
  --disable-sndio
  --disable-schannel
  # --disable-sdl2
  --disable-securetransport
  --disable-vulkan
  --disable-xlib
  --disable-zlib
  --disable-amf
  --disable-audiotoolbox
  --disable-cuda
  --disable-cuvid
  --disable-d3d11va
  --disable-dxva2
  --disable-ffnvcodec
  --disable-nvdec
  --disable-nvenc
  --disable-v4l2-m2m
  --disable-vaapi
  --disable-vdpau
  --disable-videotoolbox
  --disable-cuda-llvm

  --disable-encoders
  --enable-encoder=s24le
  --enable-encoder=pcm_s16le
  --enable-encoder=pcm_s24le
  --enable-encoder=pcm_f32le_planar
  --disable-decoders
  --enable-decoder=pcm_s16le
  --enable-decoder=pcm_s24le
  --enable-decoder=pcm_f32le_planar
  --enable-decoder=opus
  --disable-hwaccels
  --disable-muxers
  --enable-muxer=wav
  # for pcm audio
  --enable-muxer=s16le
  --enable-muxer=s24le
  --enable-muxer=f32le
  --enable-muxer=pcm
  --enable-muxer=pcm_s16le
  --enable-muxer=pcm_s24le
  --enable-muxer=pcm_f32le
  --enable-muxer=pcm_f32le_planar
  --disable-demuxers
  # enable decode of .wav files
  --enable-demuxer=wav
  # enable decode of .webm files
  --enable-demuxer=matroska
  # enable decode of .opus files
  --enable-demuxer=ogg
  --disable-parsers
  --enable-parser=opus
  --enable-parser=s24le
  --enable-parser=s16le
  --enable-parser=f32le
  --enable-parser=f32le_planar
  --enable-parser=pcm
  --disable-bsfs
  # --disable-protocols # z.wav: Protocol not found, Did you mean file:z.wav?, adds 40kb
  --disable-indevs
  --disable-outdevs
  --disable-devices
  --disable-filters
  --enable-filter=anull
  --enable-filter=aformat
  --enable-filter=aresample

  # assign toolchains and extra flags
  --nm=emnm
  --ar=emar
  --ranlib=emranlib
  --cc=emcc
  --cxx=em++
  --objcc=emcc
  --dep-cc=emcc
  --extra-cflags="$CFLAGS"
  --extra-cxxflags="$CXXFLAGS"

  # disable thread when FFMPEG_ST is NOT defined
  # ${FFMPEG_ST:+ --disable-pthreads --disable-w32threads --disable-os2threads}
  --disable-pthreads --disable-w32threads --disable-os2threads
)

emconfigure ./configure "${CONF_FLAGS[@]}" $@
emmake make -j
