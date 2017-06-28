# Adblock
cat << 'EOF' > /tmp/adblock.sh
wget -qO- "http://winhelp2002.mvps.org/hosts.txt" | awk '/^0.0.0.0/' > /tmp/block.build.list
wget -qO- "http://www.malwaredomainlist.com/hostslist/hosts.txt" | awk '{sub(/^127.0.0.1/, "0.0.0.0")} /^0.0.0.0/' >> /tmp/block.build.list
wget -qO- "http://hosts-file.net/ad_servers.txt" | awk '{sub(/^127.0.0.1/, "0.0.0.0")} /^0.0.0.0/' >> /tmp/block.build.list
wget -qO- "http://adaway.org/hosts.txt" | awk '{sub(/^127.0.0.1/, "0.0.0.0")} /^0.0.0.0/' >> /tmp/block.build.list
wget -qO- "http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&mimetype=plaintext" | awk '{sub(/^127.0.0.1/, "0.0.0.0")} /^0.0.0.0/' >> /tmp/block.build.list
wget -qO- "http://sysctl.org/cameleon/hosts" | awk '{sub(/^127.0.0.1/, "0.0.0.0")} /^0.0.0.0/' >> /tmp/block.build.list
awk '{sub(/\r$/,"");print $1,$2}' /tmp/block.build.list|sort -u > /tmp/adblock_hosts
rm -f /tmp/block.build.list
killall -HUP dnsmasq
sleep 5
rm -f /tmp/adblock_hosts
echo 3 > /proc/sys/vm/drop_caches
EOF
chmod +x /tmp/adblock.sh
