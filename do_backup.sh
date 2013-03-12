#!/bin/bash

BACKUP_DIRS=(
	'/data/backup'
	'/data/ckan'
	'/data/gitorious'
	'/data/opt'
	'/data/postgresql-data'
	'/data/test_data'
	'/data/trac'
	'/data/trac_backup'
	'/data/trac_pokergcs_users'
	'/data/trac_users'
	'/data/www'
)

YEAR=`date +%Y`
MONTH=`date +%B`
WEEK=`date +%-W`
WEEKOFMONTH=`echo "$WEEK % 5" | bc`
DAY=`date +%A`
DAYNUMBER=`date +%-d`

echo year $YEAR
echo month $MONTH
echo week $WEEK
echo weekofmonth $WEEKOFMONTH
echo day $DAY
echo daynumber $DAYNUMBER
printf "%s\n" "${BACKUP_DIRS[@]}"

cd /root/backup

function rotate {
	rm -rf daily/7
	mv daily/6 daily/7
	mv daily/5 daily/6
	mv daily/4 daily/5
	mv daily/3 daily/4
	mv daily/2 daily/3
	mv daily/1 daily/2
	mv daily/0 daily/1
	mkdir daily/0
}

function dobackup {
	TO=$1

	echo In backup...
	for BDIR in "${BACKUP_DIRS[@]}"
	do
		rsync -axp --delete --link-dest=/root/backup/daily/1 $BDIR $TO
	done
}

function docp {
	TO=$1

	echo In copy...
	cp -al /root/backup/daily/0 $TO
}

function dobackup_yearly {
	echo Yearly backup...
	
	DIR=/root/backup/yearly/$YEAR
	docp $DIR
}

function dobackup_monthly {
	echo Monthly backup...
	
	DIR=/root/backup/monthly/$MONTH
	rm -rf $DIR
	docp $DIR
}

function dobackup_weekly {
	echo Weekly backup...
	
	DIR=/root/backup/weekly/$WEEKOFMONTH
	rm -rf $DIR
	docp $DIR
}

function dobackup_daily {
	echo Daily backup...

	DIR=/root/backup/daily/0
	dobackup $DIR
}

rotate
dobackup_daily

if [ ! -d "/root/backup/yearly/$YEAR" ]; then
	dobackup_yearly
fi

if [ "$DAYNUMBER" == "1" ]; then
	dobackup_monthly
fi

if [ "$DAY" == "Sunday" ]; then
	dobackup_weekly
fi

