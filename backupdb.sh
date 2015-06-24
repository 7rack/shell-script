#! /bin/bash
set -e

USER="root"
PASSWORD='123456'

# 数据库数据目录
DATA_DIR="/opt/data/app_3306"
BIN_INDEX=$DATA_DIR"/log/app-192_168_0_168.index"

# 数据备份目录
BACKUP_DIR="/opt/backup/app"
DATE=`date +"%y%m%d"`
week=`date +%w`
LOG_TIME=`date +"%y-%m-%d %H:%M:%S"`

# binlog备份目录
RMTHOST="192.168.0.103"
RMTBACKUP_DIR="/data1/dbbak/binlog/app"
BACKUP_LOG=$DATA_DIR"/log/backup.log"

DELETE_BINLOG_NUM=10
DELETE_BINLOG_POS=$DELETE_BINLOG_NUM+1

note() {
	printf "[$LOG_TIME] note: $*\n" >> $BACKUP_LOG;
}
warning() {
	printf "[$LOG_TIME] warning: $*\n" >> $BACKUP_LOG;
}
error() {
	printf "[$LOG_TIME] error: $*\n" >> $BACKUP_LOG;
	exit 1;
}

## 备份binlog(基于文件名,也可以基于时间备份)，并清除本地binlog,释放空间。
increment_backup() {
	local BIN_NUM=`wc -l $BIN_INDEX`
	if (( $BIN_NUM < $DELETE_BINLOG_NUM ))
	then
		error "backup BINLOG failed,pls check binlog number"
	fi

	filename=`head -n $DELETE_BINLOG_NUM $BIN_INDEX`
	purgename=`sed -ne "${DELETE_BINLOG_POS}p" $BIN_INDEX|awk -F'/' '{print $7}'`

	note "increment backup start ..."
	for i in $filename
	do
		#echo "rsync $i"
		rsync -avzPh -e 'ssh -p22' --bwlimit=512 "$i" $RMTHOST:$RMTBACKUP_DIR || { error "BINLOG $i backup failed"; continue;}

	done
	/opt/mysql/bin/mysql -S /tmp/mysql3306.sock -u$USER -p$PASSWORD \
		-e "purge binary logs to '$purgename';" && note "delete logs before $purgename "
	#echo 'purge binary logs'
	note "increment backup end."
}

# 保留1周以内的备份，及56天以内每周一份。 
full_backup() {
	local dbs=`ls -l $DATA_DIR | grep "^d" | awk -F " " '{print $9}'`
	for db in $dbs
	do
		local backup_dir=$BACKUP_DIR
		local filename=$db"."$DATE
		local backup_file=$backup_dir"/"$filename".sql"
		if [ ! -d $backup_dir ]
		then
			mkdir -p $backup_dir || { error "create $db full backup $backup_dir failed"; continue; }
			note "databases $db full backup $backup_dir created";
		fi
		note "full backup $db start ..."
		#针对myisam引擎,InnoDB可使用XtraBackup
		/opt/mysql/bin/mysqldump --user=${USER} --password=${PASSWORD} \
			--master-data=2 -l --databases "$db" > $backup_file || { warning "database $db backup failed"; continue; }
		note "database $db backup success";
		note "full backup $db end."
		cd $backup_dir
		case $week in
			1)
				date=`date -d '56 days ago' +%y%m%d`
				OldFile=$db"."$date".sql"
				if [ -f $OldFile ]
				then
					rm -f $OldFile  && note "delete 56 days ago backup file $OldFile"
				fi
				;;
			2|3|4|5|6|0)
				date=`date -d '7 days ago' +%y%m%d`
				OldFile=$db"."$date".sql"
				if [ -f $OldFile ]
				then
					rm -f $OldFile && note "delete 7 days ago backup file $OldFile"
				fi
				;;
		esac
	done
}

case "$1" in
	f)
		full_backup
		;;
	i)
		increment_backup
		;;
	*)
		exit 2
		;;
esac
