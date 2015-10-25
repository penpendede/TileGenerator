#! /bin/bash

# set source path and properties of dem data
demfolder=data/dem/eu
demname=eudem_dem
demdatum=EPSG:4258

# set target path and name prefix
shadefolder=data/hillshade/eu
combined=eudem

# set source path and properties of overlay dem data
overlayfolder=data/dem/austria
overlayfile=dhm_lamb_10m
overlaydatum=EPSG:31287
overlayoptions="-tr 35 35"

# options for gdal (float)
options="-co BIGTIFF=YES -co TILED=YES -co COMPRESS=DEFLATE -co PREDICTOR=3"
# options for gdal (8bit-rgba)
hs_options="-co BIGTIFF=YES -co TILED=YES -co COMPRESS=DEFLATE -co PREDICTOR=2"

# delete old file list for vrt generation
rm $shadefolder/$combined-3785.txt
rm $shadefolder/$combined-3785-hs.txt
 
# loop over all geo-tiffs in source folder 
for file in $demfolder/*.tif 
do
    # extract filename w/o extension
    base=`basename $file .tif`
    echo "processing" $base.tif
    
    # reproject source file if not already done
    if [ ! -f $shadefolder/$base-3785.tif ]
    then
      echo "Reprojecting" $base.tif
      gdalwarp -s_srs $demdatum -t_srs EPSG:3785 -dstnodata none -r bilinear -overwrite $options $file $shadefolder/$base-3785.tif
    fi
    echo $shadefolder/$base-3785.tif >> $shadefolder/$combined-3785.txt
    
    if [ ! -f $shadefolder/$base-3785-hs.tif ]
    then
      echo "Generating hill shading from" $base-3785.tif
      gdaldem hillshade -z 3 -alt 45 -combined -alg ZevenbergenThorne -compute_edges $hs_options $shadefolder/$base-3785.tif $shadefolder/$base-3785-hs.tif
      echo "Generating overviews for" $base-3785-hs.tif
      gdaladdo -r average $shadefolder/$base-3785-hs.tif 2 4 8 16 32
    fi
    echo $shadefolder/$base-3785-hs.tif >> $shadefolder/$combined-3785-hs.txt
    
    echo ""
done  


echo "Reprojecting" $overlayfile.tif
#gdalwarp -s_srs $overlaydatum -t_srs EPSG:3785 -dstnodata none -r bilinear -overwrite $overlayoptions $options $overlayfolder/$overlayfile.tif $shadefolder/$overlayfile-3785.tif
echo $shadefolder/$overlayfile-3785.tif >> $shadefolder/$combined-3785.txt

echo "Generating hill shading from" $overlayfile-3785.tif
#gdaldem hillshade -z 2 -alt 45 -combined -compute_edges $shadefolder/$overlayfile-3785.tif $shadefolder/$overlayfile-3785-hs.tif

echo "Generating overviews for" $overlayfile-3785-hs.tif
#gdaladdo -r average $shadefolder/$overlayfile-3785-hs.tif 2 4 8 16 32

echo $shadefolder/$overlayfile-3785-hs.tif >> $shadefolder/$combined-3785-hs.txt

echo "Creating Hillshading VRT"
gdalbuildvrt -overwrite -resolution highest -srcnodata 0 -input_file_list $shadefolder/$combined-3785-hs.txt $shadefolder/$combined-3785-hs.vrt 


echo "Creating contours"
#gdalbuildvrt -overwrite -resolution highest -srcnodata 0 -input_file_list $shadefolder/$combined-3785.txt $shadefolder/$combined-3785.vrt 
#rm $shadefolder/$combined-3785-contour-low*
#gdal_contour -a elev -i 50 $shadefolder/$combined-3785.vrt $shadefolder/$combined-3785-contour-low.shp &
#rm $shadefolder/$combined-3785-contour-med*
#gdal_contour -a elev -i 20 $shadefolder/$combined-3785.vrt $shadefolder/$combined-3785-contour-med.shp &
#wait

for file in $shadefolder/*-3785.tif 
do
    base=`basename $file .tif`
    echo "processing" $base.tif
#    phyghtmap --max-nodes-per-tile=0 -s 10 -0 -o $shadefolder/$combined --pbf $shadefolder/$base-3785.tif
    echo ""
done  

dbname="contours"
#psql -U postgres -c "CREATE DATABASE $dbname;"
#psql -U postgres -q -d $dbname -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql
#psql -U postgres -q -d $dbname -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql

cnt=0
for file in $shadefolder/*local-source.osm.pbf 
do
    base=`basename $file .pbf`
    echo "importing" $base.pbf
    if (($cnt == 0)) ; then
      echo "creating"
#      osm2pgsql -C 10000 --verbose --number-processes 2 --username postgres --database $dbname --create --style $dbname.style $file
    else 
      echo "appending"
#      osm2pgsql -C 10000 --verbose --number-processes 2 --username postgres --database $dbname --append --style $dbname.style $file
    fi
    echo ""
    cnt=$(($cnt+1))
done  

echo "all done"



