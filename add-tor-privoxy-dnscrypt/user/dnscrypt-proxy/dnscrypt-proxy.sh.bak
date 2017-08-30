#!/bin/sh

dir_storage="/etc/storage"
dmconf=$dir_storage/dnsmasq/dnsmasq.conf
pws=$dir_storage/post_wan_script.sh
pis=$dir_storage/post_iptables_script.sh
files="$dmconf $pws $pis"
resolvconf=/etc/resolv.conf
hashfile=/tmp/dnscrypt-proxy.hash
sig="DNSCrypt mode"
mode=$(nvram get dnscrypt_enable)

func_clean(){
	for f in $files
	do
		sed -i "/### $sig/,/###-$sig/d" $f
	done
	grep -q 127.0.0.1 $resolvconf || sed -i '1inameserver 127.0.0.1' $resolvconf
}
func_start(){
	resolver=$(nvram get dnscrypt_resolver)
	resolver=${resolver:-cisco}
	ipaddr=$(nvram get dnscrypt_ipaddr)
	ipaddr=${ipaddr:-127.0.0.1}
	port=$(nvram get dnscrypt_port)
	port=${port:-65053}
	hash="$mode$ipaddr$port"
	if [ "$hash" != "$(cat $hashfile 2>/dev/null)" ]
	then
		notedit="(Do not manual edit this section. Use WEBUI DNSCrypt options.)"
		func_clean
		for f in $files
		do
			echo "### $sig $mode $notedit" >>$f
		done
		case $mode in
			2)
				cat >>$dmconf <<-EOF
					strict-order
					except-interface=lo
					server="${ipaddr}#${port}"
				EOF
				echo "sed -i '/$ipaddr\$/d' $resolvconf" >>$pws
				sed -i "/$ipaddr$/d" $resolvconf
			;;
			3)
				cat >>$pis <<-EOF
					if [ -n "\$(nvram get wan0_dns)" ]
					then
						iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination $ipaddr:$port
						iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination $ipaddr:$port
					else
						iptables -t nat -D OUTPUT -p udp --dport 53 -j DNAT --to-destination $ipaddr:$port
						iptables -t nat -D OUTPUT -p tcp --dport 53 -j DNAT --to-destination $ipaddr:$port
					fi
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
	/usr/bin/logger -t DNScrypt Start dnscrypt-proxy
	/usr/sbin/dnscrypt-proxy --pidfile=/var/run/dnscrypt-proxy.pid --daemonize --resolver-name=${resolver} --local-address=${ipaddr}:${port}
}
func_stop(){
	[ ${mode:-0} -eq 0 ] && {
		func_clean
		rm -f $hashfile
		restart_dhcpd
		restart_firewall
	}
	/usr/bin/logger -t DNScrypt Stop dnscrypt-proxy
	killall dnscrypt-proxy
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
