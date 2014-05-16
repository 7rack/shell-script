#! /bin/bash

workdir=/home/user/reportscript
maillist="ops@corpname.com"
attach=$(date +%h-%d-%H).tar.gz
reportdata=avemax.dat
cd  ${workdir}

#格式化 rrdtool graph PRINT 的输出（来自crontab的标准输出）
awk -F'[:]' '{printf "|%-30s|%8s %7s|%15s|\n",$1,$2,$3,$4}' ${reportdata} | sed \
       	-e 's/^|595.*/----------------------------------------------------------------/g' \
          -e '1i\---------------------------Daily   Report-----------------------'\
		-e '$a\--------------------------------------------------------------'  > reportlist.txt

#bash re.sh

#删除上一次生成的压缩包
rm *.tar.gz

tar cz -f ${attach} pngfile reportlist.txt 

#使用公司smtp服务发送邮件，需配置/etc/mailrc文件（CentOS 6.5）; error.log 来自crontab的error输出。
mailx -a ${attach} -s "Daily Report Files " $maillist < error.log 
