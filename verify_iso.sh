#!/bin/sh
#
# verify that the overlays on the iso are consistent
#

if [ ! -f overlays.iso ]; then
    echo "ERROR: no overlays.iso file"
    exit 1
fi

for novl in `cat overlays.iso`
do
    if [ ! -f ${novl}.ovl ]; then
	echo "ERROR: missing overlay $novl"
    fi
    if [ ! -f ${novl}.pkgs ]; then
	echo "ERROR: missing pkgs for overlay $novl"
    fi
done

CKDIR=/tmp/novl.$$
rm -fr $CKDIR
mkdir -p $CKDIR
if [ ! -d $CKDIR ]; then
    echo "ERROR: unable to create check directory"
    exit 2
fi

cat overlays.iso | sort > ${CKDIR}/list.orig
cat overlays.iso | sort | uniq > ${CKDIR}/list.orig.uniq

DIFF1=`diff ${CKDIR}/list.orig ${CKDIR}/list.orig.uniq`
if [ -n "$DIFF1" ]; then
    echo "ERROR: overlays.iso has duplicate entries"
fi

for novl in `cat overlays.iso`
do
    grep '^REQUIRES=' ${novl}.ovl | awk -F= '{print $2}' >> ${CKDIR}/list.orig.uniq
done
cat ${CKDIR}/list.orig.uniq | sort | uniq > ${CKDIR}/list.combo

DIFF1=`diff ${CKDIR}/list.orig ${CKDIR}/list.combo`
if [ -n "$DIFF1" ]; then
    echo "ERROR: overlays.iso has missing dependencies"
    diff ${CKDIR}/list.orig ${CKDIR}/list.combo
fi

#
# clean up
#
rm -fr $CKDIR
