#!/bin/bash

# from http://wiki.panotools.org/Panorama_scripting_in_a_nutshell
# generate a pto file

FN="temporary.pto"
OFN="blah"
FOV=98
projectionNumber=3
maskName="boardInTheMiddle.msk"

if [ ${1##*.} = "pto" ]; then
	FN=$1
else
	echo "not a valid pto name, using $FN instead"
fi

if [ -n "$2" ]; then
	FN=$2
else
	echo "not a valid output name, using $OFN instead"
fi

yaw0=90
yaw1=0
yaw2=180
yaw3=270
pitch0=0
pitch1=0
pitch2=0
pitch3=0
roll0=0
roll1=0
roll2=0
roll3=0

# echo $FN
# echo $FOV
# echo $projectionNumber
# echo $yaw0
# echo $yaw1
# echo $yaw2
# echo $yaw3
# echo $pitch0
# echo $pitch1
# echo $pitch2
# echo $pitch3
# echo $roll0
# echo $roll1
# echo $roll2
# echo $roll3

pto_gen -o $FN -f $FOV -p $projectionNumber *.jpg
pto_var -o $FN --set y0=$yaw0,p0=$pitch0,r0=$roll0 $FN
pto_var -o $FN --set y1=$yaw1,p1=$pitch1,r1=$roll1 $FN
pto_var -o $FN --set y2=$yaw2,p2=$pitch2,r2=$roll2 $FN
pto_var -o $FN --set y3=$yaw3,p3=$pitch3,r3=$roll3 $FN


# get control points
cpfind --multirow -o $FN $FN
celeste_standalone -i $FN -o $FN
cpclean -v --output $FN $FN
autooptimiser -a -l -s -o $FN $FN



# create the panorama tiff
pano_modify -s -c --canvas=AUTO --fov=360x180 -o $FN $FN
for (( i = 0; i < 4; i++ )); do
	nona  -z LZW -r ldr -m TIFF_m -o $OFN -i $i $FN
done
enblend --compression=LZW -w -f17058x4131+0+2422 -o "${OFN}.tif" -- "${OFN}0000.tif" "${OFN}0001.tif" "${OFN}0002.tif" "${OFN}0003.tif"
rm "${OFN}0000.tif" "${OFN}0001.tif" "${OFN}0002.tif" "${OFN}0003.tif"
