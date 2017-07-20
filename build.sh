#!/usr/bin/env bash
###################
# Build
# docker run -v $PWD:/build -it cloudfoundry/cflinuxfs2:1.46.0 /build/build.sh
###################

version="0.0.1"

proj_ver="4.9.3"

set -eo pipefail

release="cflinuxfs2"
cpu=$(uname -m)
vendor=/home/vcap/app/.cloudfoundry/0
echo "-----------------"
echo "Version: $version"
echo "Release: $release"
echo "CPU: $cpu"
echo "-----------------"


# apt-get update && apt-get install -y doxygen gfortran libtool libffi-dev tk-dev zlib1g-dev libfreetype6-dev libexpat1-dev groff groff-base

sandbox=/tmp/sandbox

mkdir -p $vendor/{bin,lib,include,share} $sandbox

if [[ $PATH != *$vendor* ]]; then
  export PATH=$PATH:$vendor/bin
fi

cd $sandbox

CPPFLAGS="-I$vendor/include -L$vendor/lib"
export CPPFLAGS="-I$vendor/include -L$vendor/lib"

if [ ! -f proj-$proj_ver.tar.gz ]; then
  wget https://s3.amazonaws.com/boundless-packaging/whitelisted/src/proj-$proj_ver.tar.gz
fi
tar -xvf proj-$proj_ver.tar.gz
cd proj-$proj_ver/
./configure --prefix=$vendor \
            --enable-static=no \
            --enable-shared
make install
cd $sandbox

rm -fr $vendor/include/boost
find $vendor/lib -type f -name '*.a' -exec rm -f {} +
find $vendor/lib -type f -name '*.la' -exec rm -f {} +

cd $vendor
rm -rf $vendor/lib/pkgconfig

tar -C $vendor -czf /build/vendorlibs.$version.$release.$cpu.tar.gz *
