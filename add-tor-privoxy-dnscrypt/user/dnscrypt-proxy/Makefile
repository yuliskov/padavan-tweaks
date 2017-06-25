#SRC_NAME=dnscrypt-proxy-1.6.1
SRC_NAME=dnscrypt-proxy-1.9.5
DLSITE=https://download.dnscrypt.org/dnscrypt-proxy

CFLAGS += -Os -ffunction-sections -fdata-sections
#CFLAGS += -I$(STAGEDIR)/include
LDFLAGS += -Wl,--gc-sections

all: config_test build

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi )

configure:
	( test -e $(SRC_NAME).tar.gz || wget $(DLSITE)/$(SRC_NAME).tar.gz; \
	md5sum -c md5sum || exit; \
	test -d $(SRC_NAME) || tar -xzf $(SRC_NAME).tar.gz; \
	cd $(SRC_NAME) ; \
	export CPPFLAGS="-I$(STAGEDIR)/include"; \
	autoheader; \
	autoconf; \
	./configure \
		--prefix=/usr \
		--sysconfdir=/etc/storage/dnscrypt-proxy \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD); \
	)

build:
	$(MAKE) V=1 -C $(SRC_NAME)

clean:
	rm -rf config_done dnscrypt-proxy  dnscrypt-resolvers.csv $(SRC_NAME)

romfs:
	cp -f $(SRC_NAME)/src/proxy/dnscrypt-proxy .
	wget -O dnscrypt-resolvers.csv https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/dnscrypt-resolvers.csv || cp $(SRC_NAME)/dnscrypt-resolvers.csv .
	$(STRIP) dnscrypt-proxy
	$(ROMFSINST) /usr/sbin/dnscrypt-proxy
	$(ROMFSINST) /usr/bin/dnscrypt-proxy.sh
	mkdir -p $(INSTALLDIR)/usr/share/dnscrypt-proxy
	$(ROMFSINST) dnscrypt-resolvers.csv /usr/share/dnscrypt-proxy

