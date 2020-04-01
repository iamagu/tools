#!/bin/bash
###################################
# File Name: runjar.sh
# Author: NongXinKao
###################################

# 远程执行时要注意LANG导致中文乱码问题（要在此脚本内export）
# export LANG=zh_CN.UTF-8

SCRIPT_NAME=$0

USAGE="Usage: $SCRIPT_NAME start|stop|restart|status <jar_file> [-log xx.log] [-Xms 500m] [-Xmx 1000m] [-profile dev]"

if [ $# -lt 2 ]; then
  echo $USAGE
  exit 1
fi


CMD=$1
JAR_FILE_PATH=$2
PROFILE="default"
LOG_FILE_NAME="/dev/null"

# Check file exists
if [ ! -f $JAR_FILE_PATH ];then
  echo "$JAR_FILE_PATH not exist!!!"
  exit 1
fi

cd `dirname $JAR_FILE_PATH`

JAR_ABSOLUTE_PATH="`pwd`/${JAR_FILE_PATH##*/}"

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

	"status" )
		PID=`ps -ef | grep "$JAR_ABSOLUTE_PATH" | grep -v grep |awk '{print $2}'`
		if [ "${PID}x" != "x" ]; then
		  echo "$JAR_ABSOLUTE_PATH is running."
		else
		  echo "$JAR_ABSOLUTE_PATH is not running."
		fi
	;;

	* )
  		echo $USAGE
	;;
	
	esac
}

function start()
{
	PIDS=`ps -ef | grep "java " | grep "$JAR_ABSOLUTE_PATH" | grep -v grep |awk '{print $2}'`
	
	if [ -n "$PIDS"  ]; then
	  for PID in $PIDS ; do
	      if [ "$PID"x != "x" -a $PID != $$ ]; then
		    echo "$JAR_ABSOLUTE_PATH is running."
		    exit 1
	      fi
	    done
	fi

	while [ $# -gt 2 ]
	do
	  case $3 in
		-log)
		  shift
		  if [ "$3" == "" -o "${3:0:1}" == "-" ]; then
		    echo "Missing argment value!!!"
		    exit 1
		  fi
		  LOG_FILE_NAME=$3
		  shift
		  ;;

		-profile)
		  shift
		  if [ "$3" == "" -o "${3:0:1}" == "-" ]; then
		    echo "Missing argment value!!!"
		    exit 1
		  fi
		  PROFILE=$3
		  shift
		  ;;

		-Xms)
		  shift
		  if [ "$3" == "" -o "${3:0:1}" == "-" ]; then
		    echo "Missing argment value!!!"
		    exit 1
		  fi
		  JAVA_OPTS=$JAVA_OPTS" -Xms$3"
		  shift
		  ;;

		-Xmx)
		  shift
		  if [ "$3" == "" -o "${3:0:1}" == "-" ]; then
		    echo "Missing argment value!!!"
		    exit 1
		  fi
		  JAVA_OPTS=$JAVA_OPTS" -Xmx$3"
		  shift
		  ;;

		*)
		  echo "Invalid argment!!!"
  		  echo $USAGE
		  exit 1
	  esac
	done

	nohup java $JAVA_OPTS -jar $JAR_ABSOLUTE_PATH --spring.profiles.active=$PROFILE > $LOG_FILE_NAME 2>&1 &

	echo "Start OK!!!"
}

function stop()
{
	if [ $# -ne 2 ]; then
	  echo "Usage: $SCRIPT_NAME stop <jar_file>"
	  exit 1
	fi

	PIDS=`ps -ef | grep "java " | grep -v grep | grep "$JAR_ABSOLUTE_PATH" |awk '{print $2}'`

	if [ "$PIDS"x == "x" ]; then
		echo "$JAR_ABSOLUTE_PATH is not running"
		exit 1 
	fi

	for PID in $PIDS ; do
	      if [ "$PID"x != "x" -a $PID != $$ ]; then
			echo "killing $PID ..."
			kill -9 $PID > /dev/null 2>&1
	      fi
	done
	echo "Stop OK!!!"
}

function restart()
{
	if [ $# -lt 2 ]; then
  	  echo "Usage: $SCRIPT_NAME restart <jar_file> [-log xxx.log] [-Xms 500m] [-Xmx 1000m] [-profile dev]"
	  exit 1
	fi
	
	stop $1 $2
	
	# Avoid survivor
	sleep 1 
	
	start $@
}

run $@
