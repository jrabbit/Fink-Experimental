#!/bin/sh -e
# This script is used to update the Fink Developer Map
xplanetconfig=~/Documents/fink/web/map/
xplanetmarker=~/Documents/fink/web/map/fink.xplanetmarker
output=~/Documents/fink/web/map
echo 'Benn Newman <newmanbe@freeshell.org>'
echo 'This script generates images used for the Fink Developer Map.'
echo 'y means yes; anything else means no.'
echo ''
echo 'Would you like to generate a map of the world?'
read world
echo 'Would you like to generate a map of the contiguous United States?'
read us
echo 'Would you like to generate a map of Japan?'
read japan
if [ "$world" = "y" ]; then
echo 'Generating a map of the world...'
worldmap="$output/finkmap_world.png"
worldconfig="$xplanetconfig/fink_world.xplanetconfig"
xplanet -config $worldconfig -geometry 500x500 -projection rectangular -output $worldmap -num_times 1
echo 'Done.'
fi
if [ "$us" = "y" ]; then
echo 'Generating a map of the contiguous United States...'
usmap="$output/finkmap_us.png"
usconfig="$xplanetconfig/fink_us.xplanetconfig"
xplanet -config $usconfig -geometry 100x100 -projection rectangular -output $usmap -num_times 1
#echo 'A map of the contiguous United States could not be generated.'
echo 'Done.'
fi
if [ "$japan" = "y" ]; then
echo 'Generating a map of Japan...'
usmap="$output/finkmap_jp.png"
#xplanet -config $xplanetconfig -geometry 100x100 -projection rectangular -output $usmap -num_times 1
echo 'A map of Japan could not be generated.'
echo 'Done.'
fi
