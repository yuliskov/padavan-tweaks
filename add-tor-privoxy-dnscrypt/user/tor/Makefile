SRC_NAME=tor-0.3.1.9
DLSITE=https://dist.torproject.org

CFLAGS += -Os -ffunction-sections -fdata-sections
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
	test -d $(SRC_NAME) || tar -xzf $(SRC_NAME).tar.gz; \
	cd $(SRC_NAME) ; \
	./configure \
		--prefix=/usr \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) \
		--prefix=/usr \
		--sysconfdir=/etc/storage \
		--disable-tool-name-check \
		--disable-gcc-hardening \
		--disable-asciidoc \
		--disable-systemd; \
	)

build:
	$(MAKE) V=1 -C $(SRC_NAME)

clean:
	rm -rf config_done tor $(SRC_NAME) GeoLite2-Country.mmdb*

romfs:
	cp $(SRC_NAME)/src/or/tor .
	$(STRIP) tor
	$(ROMFSINST) /usr/sbin/tor
	$(ROMFSINST) -p +x /usr/bin/tor.sh
	mkdir -p $(INSTALLDIR)/usr/share/tor
ifeq ($(CONFIG_FIRMWARE_INCLUDE_TOR_GEOIP),y)
	cp $(SRC_NAME)/src/config/geoip .
	$(ROMFSINST) /usr/share/tor/geoip
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_TOR_GEOIPV6),y)
ifeq ($(CONFIG_FIRMWARE_ENABLE_IPV6),y)
	cp $(SRC_NAME)/src/config/geoip6 .
	$(ROMFSINST) /usr/share/tor/geoip6
endif
endif

