#!/bin/bash
#
# Don't forget to grid-proxy-init -rfc
#
# This script expects exactly two arguments
#  1) the ifo for which to get the spectra
#  2) the gps start time for which to get the spectra
# The arguments must be specified in that order.
#
# Example:
#  ./getspectrum.sh H1 941365351
#


#
# parse command line
#
if [ $# -ne 2 ]
then
echo "Insufficient or too many options specified."
exit 1
fi

detector=$1
gpsstarttime=$2

if [ $detector = 'V1' ]; then
    type="HrecV3"
    channelname="${detector}:h_16384Hz"
else
    type="${detector}_LDAS_C02_L2"
    channelname="${detector}:LDAS-STRAIN"
fi


observatory=$(echo $detector | cut -b 1)
gpsendtime=$(($gpsstarttime + 2048))
output="$observatory-$type-$gpsstarttime-$gpsendtime.cache"
framecache="$output"

#
# find frame files for computing spectra
#
ligo_data_find --observatory $observatory --url-type file --gps-start-time $gpsstarttime --gps-end-time $gpsendtime --output $output --lal-cache --type $type

#
# compute spectra
#
if [ $detector = 'V1' ]; then

    lalapps_tmpltbank --grid-spacing Hexagonal --dynamic-range-exponent 69.0 --enable-high-pass 30.0 --high-pass-order 8 --strain-high-pass-order 8 --maximum-mass 15.0 --approximant TaylorF2 --gps-end-time $gpsendtime --calibrated-data real_4 --channel-name $channelname --space Tau0Tau3 --number-of-segments 1023 --minimal-match 0.97 --debug-level 33 --gps-start-time $gpsstarttime --high-pass-attenuation 0.1 --min-high-freq-cutoff SchwarzISCO --segment-length 65536 --low-frequency-cutoff 40.0 --pad-data 8 --num-freq-cutoffs 1 --sample-rate 16384 --high-frequency-cutoff 2048.0 --resample-filter ldas --strain-high-pass-atten 0.1 --strain-high-pass-freq 30 --frame-cache $framecache --max-high-freq-cutoff SchwarzISCO --user-tag FULL_DATA --chirp-mass-cutoff 2.612 --write-compress --minimum-mass 1.0 --order twoPN --spectrum-type median --write-strain-spectrum --verbose

else

    lalapps_tmpltbank --grid-spacing Hexagonal --dynamic-range-exponent 69.0 --enable-high-pass 30.0 --high-pass-order 8 --strain-high-pass-order 8 --maximum-mass 99.0 --user-tag DATAFIND --gps-end-time $gpsendtime --calibrated-data real_8 --channel-name $channelname --space Tau0Tau3 --number-of-segments 1023 --minimal-match 0.97 --debug-level 33 --gps-start-time $gpsstarttime --high-pass-attenuation 0.1 --min-high-freq-cutoff LRD --segment-length 65536 --low-frequency-cutoff 40.0 --pad-data 8 --num-freq-cutoffs 1 --sample-rate 16384 --high-frequency-cutoff 8192.0 --resample-filter ldas --strain-high-pass-atten 0.1 --strain-high-pass-freq 30 --min-total-mass 25.0 --max-total-mass 26.0 --frame-cache $framecache --max-high-freq-cutoff LRD --approximant IMRPhenomB --write-compress --minimum-mass 1.0 --order twoPN --spectrum-type median --write-strain-spectrum --verbose

fi
