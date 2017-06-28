#!/bin/sh

MY_NAME=`basename "$0"`
SVC_NAME="$MY_NAME"
# find privoxy port: netstat -lnp | grep privoxy
SVC_PORT=8118
REDIRECT_CONFIG="/etc/storage/my_scripts/redirect_config"
SRC_IP_LIST=""

# toggle transparency mode (aka redirection mode)
func_toggle_redirect()
{
	[ ! -f "$REDIRECT_CONFIG" ] && echo "$REDIRECT_CONFIG does not exist...skipping transparency mode" && return

	enabled=$1

	. "$REDIRECT_CONFIG"

	RULE_PATTERN="iptables -t nat %s PREROUTING --src %s ! --dest my.router -p tcp --dport 80 -j REDIRECT --to-ports $SVC_PORT"

	SRC_IP_MSG=""

	for SRC_IP in $SRC_IP_LIST;
	do
	    eval `printf "$RULE_PATTERN" -C $SRC_IP` 2> /dev/null
	    # 0 - rule exists, 1 - rule not exist
	    res=$?
	    [[ $res == 1 && $enabled == 1 ]] && eval `printf "$RULE_PATTERN" -A $SRC_IP` && SRC_IP_MSG="$SRC_IP_MSG$SRC_IP, "
	    [[ $res == 0 && $enabled == 0 ]] && eval `printf "$RULE_PATTERN" -D $SRC_IP` && SRC_IP_MSG="$SRC_IP_MSG$SRC_IP, "
	done

	if [ ! -z "$SRC_IP_MSG" ]; then
		# remove last two chars
		SRC_IP_MSG=${SRC_IP_MSG%??}
		REDIRECT_MSG="%s redirection to port $SVC_PORT for clients: %s"
		ACTION_MSG=`[ $enabled == 1 ] && echo "enable" || echo "disable"`
		RESULT_MSG=`printf "$REDIRECT_MSG" "$ACTION_MSG" "$SRC_IP_MSG"`
	else
		RESULT_MSG="nothing to do"
	fi

	echo "$RESULT_MSG" && logger -t "$SVC_NAME" "$RESULT_MSG"
}

case "$1" in
enable|on|start)
	func_toggle_redirect 1
	;;
disable|off|stop)
	func_toggle_redirect 0
	;;
*)
	echo "Usage: $0 {enable|disable}"
	exit 1
	;;
esac