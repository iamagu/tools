#!/bin/bash
###################################
# File Name: javaapp.sh
# Author: nongxinkao
###################################

cd `dirname $0`

WORK_DIR=`pwd`

FILE=$0
CMD=$1
JAR_FILE=
PARAM=$3
PARAMS=$#

case $2 in
  odr)
    JAR_FILE="otc-order-service-1.0-SNAPSHOT.jar"
    ;;

  mbr)
    JAR_FILE="otc-member-service-1.0-SNAPSHOT.jar"
    ;;

  acc)
    JAR_FILE="otc-account-service-1.0-SNAPSHOT.jar"
    ;;

  gw)
    JAR_FILE="otc-zuul-gateway-1.0-SNAPSHOT.jar"
    ;;

  sc)
    JAR_FILE="otc-schedule-1.0-SNAPSHOT.jar"
    ;;

  co)
    JAR_FILE="otc-config-service-1.0-SNAPSHOT.jar"
    ;;

  r)
    JAR_FILE="otc-registry-server-1.0-SNAPSHOT.jar"
    ;;
  adm)
    JAR_FILE="otc-admin-web-1.0-SNAPSHOT.jar"
    ;;
  msg)
    JAR_FILE="otc-message-service-1.0-SNAPSHOT.jar"
    ;;
  wltapi)
    JAR_FILE="otc-wallet-api-1.0-SNAPSHOT.jar"
    ;;
  wltjob)
    JAR_FILE="otc-wallet-job-1.0-SNAPSHOT.jar"
    ;;
  *)
    ;;
esac

if [ "$PARAMS" -eq "0" ]; then
  echo "Usage: start|stop|restart <program_name> [-log xxx.log] [-Xms 500m] [-Xmx 1000m]"
  exit 1
fi


function run()
{
	case $CMD in

	"start" )
		start
	;;

	"stop" )
		stop
	;;

	"restart" )
		restart
	;;

	* )
		echo "[Info] please use $FILE [start|stop|restart]"
	;;
	
	esac
}

function start()
{
	if [ $PARAMS -lt 2 ]; then
		echo "Usage: $FILE start|stop|restart <program_name> [-log xxx.log] [-Xms 500m] [-Xmx 1000m]"
		exit 1
	fi

	PIDS=`ps -ef | grep java | grep -v grep | grep "$JAR_FILE" |awk '{print $2}'`

	if [ -n "$PIDS"  ]; then
	  for PID in $PIDS ; do
	      if [ "$PID"x != "x" -a $PID != $$ ]; then
		echo "$WORK_DIR/$JAR_FILE is running, please kill the process first."
		exit 1
	      fi
	    done
	fi

	# Leave the parameters
	shift

	while [ $PARAMS -gt 3 ]
	do
	  case $PARAM in
		-log)
		  shift
		  LOG_FILE_NAME=$PARAM
		  shift
		  ;;

		-Xms)
		  JAVA_OPTS=$JAVA_OPTS" -Xms"
		  shift
		  JAVA_OPTS=$JAVA_OPTS"$PARAM"
		  shift
		  ;;

		-Xmx)
		  JAVA_OPTS=$JAVA_OPTS" -Xmx"
		  shift
		  JAVA_OPTS=$JAVA_OPTS"$PARAM"
		  shift
		  ;;
	  esac
	done

	nohup java -Xmx1024m -jar $JAR_FILE --spring.profiles.active=test > /dev/null 2>&1 &

	echo "Start OK!!!"
}

function stop()
{
	if [ $PARAMS -ne 2 ]; then
	  echo "Usage: $FILE stop <program_name>"
	  exit
	fi

	PIDS=`ps -ef | grep java | grep -v grep | grep "$JAR_FILE" |awk '{print $2}'`

	for PID in $PIDS ; do
		echo "killing $PID ..."
		kill -9 $PID > /dev/null 2>&1
	done
}

function restart()
{
	if [ $PARAMS -ne 2 ]; then
	  echo "Usage: $FILE restart <program_name>"
	  exit
	fi
	
	stop
	sleep 1s
	start
}

run
