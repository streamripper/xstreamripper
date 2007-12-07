#!/bin/sh
# shell script goes here
root=`pwd`
libogg=`echo libogg-* | head -1`
liboggfull=$root/$libogg
libvorbis=`echo libvorbis-* | head -1`
libvorbisfull=$root/$libvorbis

rm -f libvorbis && ln -s $libvorbis libvorbis
rm -f libogg && ln -s $libogg libogg

cd $liboggfull
if [ ! -r config.status ] ; then
  ./configure --enable-static=YES --enable=shared=NO
  make
  rm -f libogg.a && ln -s src/.libs/libogg.a .
fi

cd $libvorbisfull
if [ ! -r config.status ] ; then
  ./configure --enable-static=YES --enable-shared=NO --with-ogg-libraries=$liboggfull --with-ogg-includes=$liboggfull/include
  make
  rm -f libvorbis.a && ln -s lib/.libs/libvorbis.a .
  rm -f libvorbisenc.a && ln -s lib/.libs/libvorbisenc.a .
  rm -f libvorbisfile.a && ln -s lib/.libs/libvorbisfile.a .
fi

cd $root/streamripper
if [ ! -r config.status ] ; then
  ./configure --enable-static=YES --enable-shared=NO --with-ogg-libraries=$liboggfull --with-ogg-includes=$liboggfull/include --with-vorbis-libraries=$libvorbisfull --with-vorbis-includes=$libvorbisfull/include
  make
  libmadname=`echo libmad* | head`
  rm -f libmad.a
  ln -s $libmadname/.libs/libmad.a libmad.a
  libtrename=`echo tre* | head`
  rm -f libtre.a
  ln -s $libtrename/lib/.libs/libtre.a libtre.a
fi
exit 0
