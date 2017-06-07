SRC_NAME=tinyproxy-1.9.0

CFLAGS  += -ffunction-sections -fdata-sections
CXXFLAGS += -ffunction-sections -fdata-sections
LDFLAGS += -Wl,--gc-sections

THISDIR = $(shell pwd)

all: config_test
	$(MAKE) -C $(SRC_NAME) && \
	$(MAKE) -C $(SRC_NAME) install DESTDIR=$(THISDIR)/install

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi )

configure:
	( test -d $(SRC_NAME) || tar -xzf $(SRC_NAME)-src.tar.gz; \
	cd $(SRC_NAME) ; \
	./configure \
		--prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--enable-transparent \
		--enable-filter \
		--enable-regexcheck=no \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) distclean ; \
	fi ; \
	rm -f config_done
	rm -rf install

romfs:
	mkdir -p $(INSTALLDIR)/etc_ro/tinyproxy
	cp -af $(THISDIR)/install/etc/. $(INSTALLDIR)/etc_ro/tinyproxy
	cp -af $(THISDIR)/my_files/. $(INSTALLDIR)/etc_ro/tinyproxy
	cp -af $(THISDIR)/install/usr/sbin/. $(INSTALLDIR)/usr/bin/
	cp -af $(THISDIR)/install/usr/share/. $(INSTALLDIR)/usr/share/
	$(ROMFSINST) -p +x /usr/bin/tinyproxy.sh
	
