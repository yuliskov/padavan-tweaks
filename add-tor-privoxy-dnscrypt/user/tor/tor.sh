#!/bin/sh

dir_storage="/etc/storage/tor"
tor_config="$dir_storage/torrc"

func_create_config()
{
	ip_address=`ip address show br0 | grep -w inet | sed 's|.* \(.*\)/.*|\1|'`
	cat > "$tor_config" <<EOF
## See https://www.torproject.org/docs/tor-manual.html,
## for more options you can use in this file.

SocksPort 127.0.0.1:9050
SocksPort ${ip_address}:9050
DataDirectory /tmp/tor
User admin
Log notice syslog
#ExcludeExitNodes {ru},{by},{ua}
#ExitNodes {fr},{be},{cz},{nl}
#StrictNodes 1
EOF
	chmod 644 "$tor_config"
	/sbin/mtd_storage.sh save
}

func_start()
{
	test -d "$dir_storage" || mkdir -p -m 755 $dir_storage
	if [ ! -f "$tor_config" ] ; then
		func_create_config
	fi
	if [ -d "/opt/share/tor" ]
	then
		mount | grep -q /usr/share/tor || mount --bind /opt/share/tor /usr/share/tor
	fi
	/usr/bin/logger -t tor Start TOR
	/usr/sbin/tor --runasdaemon 1 --pidfile /var/run/tor.pid
}

func_stop()
{
	/usr/bin/logger -t tor Stop TOR
	killall -q tor
	umount -l /usr/share/tor
	rm -rf /tmp/tor
}

func_reload()
{
	/usr/bin/logger -t tor Restart TOR
	kill -SIGHUP `cat /var/run/tor.pid`
}

case "$1" in
start)
	func_start $2
	;;
stop)
	func_stop
	;;
reload)
	func_reload
	;;
*)
	echo "Usage: $0 {start|stop|reload}"
	exit 1
	;;
esac

exit 0
