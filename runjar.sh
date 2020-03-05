#!/bin/bash
###################################
# File Name: runjar.sh
# Author: NongXinKao
###################################

# 远程执行时要注意LANG导致中文乱码问题（要在此脚本内export）
# export LANG=zh_CN.UTF-8

cd `dirname $0`

WORK_DIR=`pwd`

SCRIPT_NAME=$0
CMD=$1
JAR_FILE=$2
PROFILE="default"
LOG_FILE_NAME="/dev/null"

if [ $# -lt 2 ]; then
  echo "Usage: $SCRIPT_NAME start|stop|restart <program_name> [-log xxx.log] [-Xms 500m] [-Xmx 1000m] [-profile dev]"
  exit 1
fi



function run()
{
	case $CMD in

	"start" )
		start $@
	;;

	"stop" )
		stop $@
	;;

	"restart" )
		restart $@
	;;

	* )
  		echo "Usage: $SCRIPT_NAME start|stop|restart <program_name> [-log xxx.log] [-Xms 500m] [-Xmx 1000m]"
	;;
	
	esac
}

function start()
{
	# Avoid survivor
	sleep 1 

	PIDS=`ps -ef | grep "java " | grep "$WORK_DIR/$JAR_FILE" | grep -v grep |awk '{print $2}'`
	
	# Transfer to arr
	#str=${PIDS// / };
	#arr=($str);
	#if [ ${#arr[*]} -gt 2 ]; then
	#  echo "$WORK_DIR/$JAR_FILE is running, please kill the process first."
	#  exit 1
	#fi

	if [ -n "$PIDS"  ]; then
	  for PID in $PIDS ; do
	      if [ "$PID"x != "x" -a $PID != $$ ]; then
		echo "$WORK_DIR/$JAR_FILE is running, please kill the process first."
		exit 1
	      fi
	    done
	fi

	while [ $# -gt 2 ]
	do
	  case $3 in
		-log)
		  shift
		  LOG_FILE_NAME=$3
		  shift
		  ;;

		-profile)
		  shift
		  PROFILE=$3
		  shift
		  ;;

		-Xms)
		  JAVA_OPTS=$JAVA_OPTS" -Xms"
		  shift
		  JAVA_OPTS=$JAVA_OPTS"$3"
		  shift
		  ;;

		-Xmx)
		  JAVA_OPTS=$JAVA_OPTS" -Xmx"
		  shift
		  JAVA_OPTS=$JAVA_OPTS"$3"
		  shift
		  ;;
	  esac
	done

	nohup java $JAVA_OPTS -jar $WORK_DIR/$JAR_FILE --spring.profiles.active=$PROFILE > $LOG_FILE_NAME 2>&1 &

	echo "Start OK!!!"
}

function stop()
{
	if [ $# -ne 2 ]; then
	  echo "Usage: $SCRIPT_NAME stop <program_name>"
	  exit
	fi

	PIDS=`ps -ef | grep "java " | grep -v grep | grep "$WORK_DIR/$JAR_FILE" |awk '{print $2}'`

	for PID in $PIDS ; do
	      if [ "$PID"x != "x" -a $PID != $$ ]; then
		echo "killing $PID ..."
		kill -9 $PID > /dev/null 2>&1
	      fi
	done
	echo -n "Stop OK!"
}

function restart()
{
	if [ $# -lt 2 ]; then
  	  echo "Usage: $SCRIPT_NAME restart <program_name> [-log xxx.log] [-Xms 500m] [-Xmx 1000m] [-profile dev]"
	  exit
	fi
	
	stop $1 $2
	start $@
}

run $@
