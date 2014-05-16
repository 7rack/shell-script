#! /bin/bash

#12h前
starttime=$(date --date='12 hour ago' +%s)  #or date -d '-12 hour'
# now
endtime=$(date +%s)

for rrdfile in ./meetme/*.rrd
do
##取得文件名，以用来命名title,及png文件名
filename=$(basename ${rrdfile} .rrd)

#画图
rrdtool graph ./pngfile/${filename}.png \
--imgformat=PNG \
--start=${starttime} \
--end=${endtime} \
--title="${filename}" \
--base=1000 \
--height=120 \
--width=500 \
--alt-autoscale-max \
--lower-limit='0' \
COMMENT:"From $(date --date='-12 hour' "+%Y/%m/%d %H\:%M\:%S") To $(date "+%Y/%m/%d %H\:%M\:%S") \c" \
COMMENT:"  \n" \
--vertical-label='bits per second' \
--slope-mode \
--font TITLE:10: \
--font AXIS:7: \
--font LEGEND:8: \
--font UNIT:7: \
DEF:a="${rrdfile}":'traffic_in':MAX \
DEF:b="${rrdfile}":'traffic_out':MAX \
CDEF:cdefa='a,8,*' \
CDEF:cdefe='b,8,*' \
CDEF:cdefi='a,8,*,1000000,/' \
CDEF:cdefo='b,8,*,1000000,/' \
AREA:cdefa#00CF00FF:"Inbound"  \
GPRINT:cdefa:LAST:" Current\:%8.2lf %s"  \
GPRINT:cdefa:AVERAGE:"Average\:%8.2lf %s"  \
GPRINT:cdefa:MAX:"Maximum\:%8.2lf %s\n"  \
LINE1:cdefe#002A97FF:"Outbound"  \
GPRINT:cdefe:LAST:"Current\:%8.2lf %s"  \
GPRINT:cdefe:AVERAGE:"Average\:%8.2lf %s"  \
GPRINT:cdefe:MAX:"Maximum\:%8.2lf %s\n" \
PRINT:cdefi:MAX:"${filename}\:Inbound\:Maximum\:%8.3lf"  \
PRINT:cdefo:MAX:"${filename}\:Outbound\:Maximum\:%8.3lf" \
PRINT:cdefi:AVERAGE:"${filename}\:Inbound\:Average\:%8.3lf"  \
PRINT:cdefo:AVERAGE:"${filename}\:Outbound\:Average\:%8.3lf"  
done
