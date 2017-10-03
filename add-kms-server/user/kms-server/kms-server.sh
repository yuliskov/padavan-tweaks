#!/bin/sh

# https://blogs.technet.microsoft.com/odsupport/2011/11/14/how-to-discover-office-and-windows-kms-hosts-via-dns-and-remove-unauthorized-instances/
# check: nslookup -type=srv _vlmcs._tcp

# A SRV record sending KMS quries to my.router and port 1688 (not working though)
# srv-host=_vlmcs._tcp,my.router,1688
# srv-host=_vlmcs._tcp.lan,${computer_name}.lan,${port},0,100

# reset and activate:
# slmgr /ckms
# slmgr /ato

dir_storage="/etc/storage"
dmconf=$dir_storage/dnsmasq/dnsmasq.conf
pws=$dir_storage/post_wan_script.sh
files="$dmconf $pws"
hashfile=/tmp/kms-server.hash
sig="KMSServer mode"
mode=$(nvram get kms_server_enable)
mode=${mode:-0}

func_clean(){
	for f in $files
	do
		sed -i "/### $sig/,/###-$sig/d" $f
	done
}
func_start(){
	ipaddr=$(nvram get kms_server_ipaddr)
	ipaddr=${ipaddr:-0.0.0.0}
	port=$(nvram get kms_server_port)
	port=${port:-1688}
	computer_name=`nvram get computer_name`
	hash="$mode$ipaddr$port"
	if [ "$hash" != "$(cat $hashfile 2>/dev/null)" ]
	then
		notedit="(Do not manual edit this section. Use WEBUI KMSServer options.)"
		func_clean
		for f in $files
		do
			echo "### $sig $mode $notedit" >>$f
		done
		case $mode in
			1)
				cat >>$dmconf <<-EOF
					srv-host=_vlmcs._tcp.lan,${computer_name}.lan,${port},0,100
				EOF
				cat >>$pws <<-EOF
					/usr/bin/kms-server.sh restart
				EOF
			;;
		esac
		for f in $files
		do
			echo "###-$sig $mode" >>$f
		done
		echo $hash >$hashfile
		restart_dhcpd
		restart_firewall
	fi
	/usr/bin/logger -t KMSServer Start vlmcsd
	if [ -f /etc_ro/vlmcsd.kmd ]; then
		/usr/bin/vlmcsd -j /etc_ro/vlmcsd.kmd -l syslog -L ${ipaddr}:${port}
	else
		/usr/bin/vlmcsd -l syslog -L ${ipaddr}:${port}
	fi
}
func_stop(){
	[ ${mode:-0} -eq 0 ] && {
		func_clean
		rm -f $hashfile
		restart_dhcpd
		restart_firewall
	}
	/usr/bin/logger -t KMSServer Stop vlmcsd
	killall vlmcsd
}

case "$1" in
start)
	func_start $2
	;;
stop)
	func_stop
	;;
restart)
	func_stop
	func_start $2
	;;
*)
	echo "Usage: $0 {start|stop|restart}"
	exit 1
	;;
esac

exit 0
