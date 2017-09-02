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
    SVC_PORT=$2
    # remove first 2 arguments
    shift 2

    RULE_PATTERN="iptables -t nat %s PREROUTING --src %s ! --dest my.router -p tcp --dport 80 -j REDIRECT --to-ports $SVC_PORT"

    SRC_IP_MSG=""
    SRC_IP_MSG_ALL=""

    for SRC_IP in "$@";
    do
        eval `printf "$RULE_PATTERN" -C $SRC_IP` 2> /dev/null
        # 0 - rule exists, 1 - rule not exist
        rule_exists=$?
        [[ $rule_exists == 1 && $enabled == 1 ]] && eval `printf "$RULE_PATTERN" -A $SRC_IP` && SRC_IP_MSG="$SRC_IP_MSG$SRC_IP, "
        [[ $rule_exists == 0 && $enabled == 0 ]] && eval `printf "$RULE_PATTERN" -D $SRC_IP` && SRC_IP_MSG="$SRC_IP_MSG$SRC_IP, "
        SRC_IP_MSG_ALL="$SRC_IP_MSG_ALL$SRC_IP, "
    done
        
    REDIRECT_MSG="%s redirection to port $SVC_PORT for clients: %s"
    [ -z "$SRC_IP_MSG" ] && REDIRECT_MSG="already done: $REDIRECT_MSG" && SRC_IP_MSG=$SRC_IP_MSG_ALL
    ACTION_MSG=`[ $enabled == 1 ] && echo "enable" || echo "disable"`
    # remove last two chars
    SRC_IP_MSG=${SRC_IP_MSG%??}
    RESULT_MSG=`printf "$REDIRECT_MSG" "$ACTION_MSG" "$SRC_IP_MSG"`

    echo "$RESULT_MSG" && logger -t "$SVC_NAME" "$RESULT_MSG"
}

case "$1" in
enable|on|start)
    # remove first argument
    shift
    func_toggle_redirect 1 8118 $@
    ;;
disable|off|stop)
    # remove first argument
    shift
    func_toggle_redirect 0 8118 $@
    ;;
*)
    echo "Usage: $0 <on|off> <target_ip>..."
    exit 1
    ;;
esac