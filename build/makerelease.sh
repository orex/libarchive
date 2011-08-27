#!/bin/sh

PATH=/usr/local/gnu-autotools/bin/:$PATH
export PATH

# Start from one level above the build directory
if [ -f version ]; then
    cd ..
fi

if [ \! -f build/version ]; then
    echo "Can't find source directory"
    exit 1
fi

# BSD make's "OBJDIR" support freaks out the automake-generated
# Makefile.  Effectively disable it.
export MAKEOBJDIRPREFIX=/junk

set -ex

/bin/sh build/clean.sh

#
# Verify the CMake-generated build
#
mkdir -p _cmtest
cd _cmtest
cmake ..
make
make test
cd ..
rm -rf _cmtest
# TODO: Build distribution using cmake

#
# Construct and verify the autoconf build system
#
/bin/sh build/autogen.sh

# Get the newest config.guess/config.sub from savannah.gnu.org
curl 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' > build/autoconf/config.guess
curl 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD' > build/autoconf/config.sub

./configure
make distcheck
make dist-zip
