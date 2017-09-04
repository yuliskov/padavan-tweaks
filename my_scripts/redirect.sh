#!/bin/sh

MY_NAME=`basename "$0"`
SVC_NAME="$MY_NAME"
# find privoxy port: netstat -lnp | grep privoxy
SVC_PORT=8118

# toggle transparency mode (aka redirection mode)
func_toggle_redirect()
{
    enabled=$1
    SVC_PORT=$2
    # remove first 2 arguments
    shift 2

    RULE_PATTERN="iptables -t nat %s PREROUTING --src %s ! --dest my.router -p tcp --dport 80 -j REDIRECT --to-ports $SVC_PORT"

    SRC_IP_MSG=""

    for SRC_IP in "$@";
    do
        eval `printf "$RULE_PATTERN" -C $SRC_IP` 2> /dev/null
        # 0 - rule exists, 1 - rule not exist
        rule_exists=$?
        [[ $rule_exists == 1 && $enabled == 1 ]] && eval `printf "$RULE_PATTERN" -A $SRC_IP` && SRC_IP_MSG="$SRC_IP_MSG$SRC_IP "
        [[ $rule_exists == 0 && $enabled == 0 ]] && eval `printf "$RULE_PATTERN" -D $SRC_IP` && SRC_IP_MSG="$SRC_IP_MSG$SRC_IP "
    done

    ACTION_MSG=`[ $enabled == 1 ] && echo "enable" || echo "disable"`
        
    if [ ! -z "$SRC_IP_MSG" ]; then
        # remove last two chars (, )
        # SRC_IP_MSG=${SRC_IP_MSG%??}
        RESULT_MSG="$ACTION_MSG redirection to port $SVC_PORT for clients: $SRC_IP_MSG"
    else
        RESULT_MSG="already ${ACTION_MSG}d for $@"
    fi

    echo "$RESULT_MSG" && logger -t "$SVC_NAME" "$RESULT_MSG"
}

case "$1" in
enable|on|start)
    # remove first argument
    shift
    func_toggle_redirect 1 $SVC_PORT $@
    ;;
disable|off|stop)
    # remove first argument
    shift
    func_toggle_redirect 0 $SVC_PORT $@
    ;;
*)
    echo "Usage: $0 <on|off> <target_ip>..."
    exit 1
    ;;
esac