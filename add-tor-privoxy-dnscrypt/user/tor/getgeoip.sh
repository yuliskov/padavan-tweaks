wget -N https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz
gunzip -c GeoLite2-Country.mmdb.gz >GeoLite2-Country.mmdb
python `dirname $0`/mmdb-convert.py GeoLite2-Country.mmdb
