#!/bin/sh

#######################################################################
# (1) run process from superuser root (less security)
# (0) run process from unprivileged user "nobody" (more security)
SVC_ROOT=0

# process priority (0-normal, 19-lowest)
SVC_PRIORITY=5
#######################################################################

SVC_NAME="Tinyproxy"
SVC_EXE="tinyproxy"
SVC_PATH="/usr/bin/tinyproxy"
DIR_STORAGE="/etc/storage/tinyproxy"

print_cmd_line()
{
	echo "-c `print_conf_path`"
}

print_conf_path()
{
	regular_path="/etc/storage/tinyproxy/tinyproxy.conf"
	alt_path="/etc_ro/tinyproxy/tinyproxy.conf"
	if [ ! -f $regular_path ]; then
		echo $alt_path
	else
		echo $regular_path
	fi
}

prepare_first_boot()
{	
	# volatile files
	cp -af /etc_ro/tinyproxy/* $DIR_STORAGE
}

######### Common Content ###########

func_start()
{
	# Make sure already running
	if [ -n "`pidof $SVC_EXE`" ] ; then
		echo "$SVC_NAME already running"
		return 0
	fi

	if [ ! -d "$DIR_STORAGE" ] ; then
		mkdir -p -m 755 $DIR_STORAGE
		msg="Preparing $SVC_NAME for first time running..."
		prepare_first_boot && echo "$msg[  OK  ]" || echo "$msg[FAILED]"
	fi
	
	echo -n "Starting $SVC_NAME:."
	
	svc_user=""
	
	# check start-stop-daemon stuff
	if [ $SVC_ROOT -eq 0 ] ; then
		svc_user=" -c nobody"
	fi
	
	start-stop-daemon -S -N $SVC_PRIORITY$svc_user -x $SVC_PATH -- `print_cmd_line`
	
	if [ $? -eq 0 ] ; then
		echo "[  OK  ]"
		logger -t "$SVC_NAME" "daemon is started"
	else
		echo "[FAILED]"
	fi
}

func_stop()
{
	# Make sure not running
	if [ -z "`pidof $SVC_EXE`" ] ; then
		echo "$SVC_NAME already stopped"
		return 0
	fi
	
	echo -n "Stopping $SVC_NAME:."
	
	# stop daemon
	killall -q $SVC_EXE
	
	# gracefully wait max 25 seconds while service stopped
	i=0
	while [ -n "`pidof $SVC_EXE`" ] && [ $i -le 25 ] ; do
		echo -n "."
		i=$(( $i + 1 ))
		sleep 1
	done
	
	tr_pid=`pidof $SVC_EXE`
	if [ -n "$tr_pid" ] ; then
		# force kill (hungup?)
		kill -9 "$tr_pid"
		sleep 1
		echo "[KILLED]"
		logger -t "$SVC_NAME" "Cannot stop: Timeout reached! Force killed."
	else
		echo "[  OK  ]"
	fi
}

func_reload()
{
	if [ -n "`pidof $SVC_EXE`" ] ; then
		echo -n "Reload $SVC_NAME config:."
		killall -SIGHUP $SVC_EXE
		echo "[  OK  ]"
	fi
}

case "$1" in
start)
	func_start
	;;
stop)
	func_stop
	;;
reload)
	func_reload
	;;
restart)
	func_stop
	func_start
	;;
*)
	echo "Usage: $0 {start|stop|reload|restart}"
	exit 1
	;;
esac