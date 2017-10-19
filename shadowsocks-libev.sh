#!/bin/bash

set -e
set -x

mkdir ~/shadowsocks-libev && cd ~/shadowsocks-libev

PREFIX=/opt
BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
DEST=$BASE$PREFIX
LDFLAGS="-L$DEST/lib -Wl,--gc-sections"
CPPFLAGS="-I$DEST/include"
CFLAGS="-mtune=mips32 -mips32 -O3 -ffunction-sections -fdata-sections"	
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=$PREFIX --host=mipsel-linux"
MAKE="make -j`nproc`"
mkdir $SRC

######## ####################################################################
# PCRE # ####################################################################
######## ####################################################################

mkdir $SRC/pcre && cd $SRC/pcre
$WGET ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.41.tar.gz
tar zxvf pcre-8.41.tar.gz
cd pcre-8.41

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--enable-unicode-properties \
--disable-shared
#--enable-pcregrep-libz \

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# MBEDTLS # #################################################################
########### #################################################################

mkdir $SRC/mbedtls && cd $SRC/mbedtls
$WGET https://tls.mbed.org/download/mbedtls-2.6.0-apache.tgz
tar zxvf mbedtls-2.6.0-apache.tgz
cd mbedtls-2.6.0

cmake \
-DCMAKE_INSTALL_PREFIX=$PREFIX \
-DCMAKE_C_COMPILER=`which mipsel-linux-gcc` \
-DCMAKE_C_FLAGS="$CFLAGS" \
-DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
./

$MAKE
make install DESTDIR=$BASE

############# ###############################################################
# LIBSODIUM # ###############################################################
############# ###############################################################

mkdir -p $SRC/libsodium && cd $SRC/libsodium
$WGET https://github.com/jedisct1/libsodium/releases/download/1.0.15/libsodium-1.0.15.tar.gz
tar zxvf libsodium-1.0.15.tar.gz
cd libsodium-1.0.15

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--enable-minimal \
--enable-static \
--disable-shared

$MAKE
#make
make install DESTDIR=$BASE

########## ##################################################################
# C-ARES # ##################################################################
########## ##################################################################

mkdir -p $SRC/c-ares && cd $SRC/c-ares
$WGET https://c-ares.haxx.se/download/c-ares-1.13.0.tar.gz
tar zxvf c-ares-1.13.0.tar.gz
cd c-ares-1.13.0

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--disable-shared

make
make install DESTDIR=$BASE

######### ###################################################################
# LIBEV # ###################################################################
######### ###################################################################

mkdir -p $SRC/libev && cd $SRC/libev
$WGET http://dist.schmorp.de/libev/libev-4.24.tar.gz
tar zxvf libev-4.24.tar.gz
cd libev-4.24

sed -i ev_epoll.c -e "/#ifdef EPOLL_CLOEXEC/,/#endif/d"

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--disable-shared

$MAKE
make install DESTDIR=$BASE

############### #############################################################
# SHADOWSOCKS # #############################################################
############### #############################################################

mkdir $SRC/shadowsocks-libev && cd $SRC/shadowsocks-libev
$WGET https://github.com/shadowsocks/shadowsocks-libev/releases/download/v3.1.0/shadowsocks-libev-3.1.0.tar.gz
tar zxvf shadowsocks-libev-3.1.0.tar.gz
cd shadowsocks-libev-3.1.0

LDFLAGS="--static $LDFLAGS" \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--disable-documentation

$MAKE
make install DESTDIR=$BASE/shadowsocks-libev
