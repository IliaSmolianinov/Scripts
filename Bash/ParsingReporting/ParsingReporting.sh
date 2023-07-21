#!/bin/bash


read -p "Введите url: " URL
wget -nv $URL   

FILE=$(echo $URL | rev | cut -f1 -d'/' | rev)

DATE=$(date +%d/%m/%y | sed s'/\//_/g')

if [[ $# == 1 ]]
then
	SERVER=$1
else
	SERVER="DEFAULT"
fi


cat $FILE | grep "CrashLoopBackOff\|Error" | cut -f1 -d' ' | sed 's/-.\{9,10\}-.\{5\}$//' >> "${SERVER}_${DATE}_failed.out"
cat $FILE | grep Running | cut -f1 -d' ' | sed 's/-.\{9,10\}-.\{5\}$//' >> "${SERVER}_${DATE}_running.out"

echo "Количество работающих сервисов: $(wc -l "${SERVER}_${DATE}_running.out" | cut -f1 -d' ')" >> "${SERVER}_${DATE}_report.out"
echo "Количество сервисов с ошибками: $(wc -l "${SERVER}_${DATE}_failed.out" | cut -f1 -d' ')" >> "${SERVER}_${DATE}_report.out"
echo "Имя системного пользователя: $USER" >> "${SERVER}_${DATE}_report.out"
echo "Дата: $(date +%d/%m/%y)" >> "${SERVER}_${DATE}_report.out"

chmod 444 "${SERVER}_${DATE}_report.out"


ARCH="./archive/${SERVER}_${DATE}.tar.gz"
if [[ ! -f $ARCH ]]
then
	tar -zcvf $ARCH "${SERVER}_${DATE}"*.out > /dev/null
	rm -f "${SERVER}_${DATE}"* $FILE
	tar -tvzf $ARCH > /dev/null

	if [[ $? == 0 ]]
	then
		echo "Архив ${SERVER}_${DATE} создан и проверен!"
		exit 0
	else
		echo "Ахив ${SERVER}_${DATE} поврежден!"
		exit 1
	fi
else
	echo "Архив $ARCH уже существует"
	rm -f "${SERVER}_${DATE}"* $FILE
	exit 1
fi


