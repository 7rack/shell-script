#! /bin/bash

###通过wget获取meetme站点的rrd文件
wget -q -P meetme/ -i meetme.lst

###通过rsync获取10.2.1.92站点rrd文件，
localdir=/home/user/reportscript/meetme

remotefile="/var/www/html/rra/juniper-mx960_traffic_in_2341.rrd \
/var/www/html/rra/juniper-mx960_traffic_in_4123.rrd \
/var/www/html/rra/juniper-mx960_traffic_in_1234.rrd "

remoteip="10.2.0.88"
remoteport="22"


[ -d ${localdir} ] || mkdir ${localdir} 

for file in ${remotefile}
  do
	rsync -aq -e "ssh -p ${remoteport}" root@${remoteip}:${file} ${localdir}
  done

#重命名所得文件，方便 rrdtool 绘图
mv  ./meetme/juniper-mx960_traffic_in_1111.rrd  ./meetme/Juniper-MX960-CT.rrd

[...]
