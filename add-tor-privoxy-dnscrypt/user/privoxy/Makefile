# http://sourceforge.net/projects/ijbswa/files/Sources
SRC_NAME=privoxy-3.0.26-stable

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
	cd $(SRC_NAME) ; autoheader && autoconf && \
	./configure \
		--prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var \
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
	# see privoxy.sh for storage install code
	mkdir -p $(INSTALLDIR)/etc_ro/privoxy
	cp -af $(THISDIR)/install/etc/* $(INSTALLDIR)/etc_ro/privoxy
	cp -af $(THISDIR)/install/usr/share/doc/privoxy $(INSTALLDIR)/usr/share
	cp -af $(THISDIR)/my_files/* $(INSTALLDIR)/etc_ro/privoxy
	$(ROMFSINST) $(THISDIR)/install/usr/sbin/privoxy /usr/bin/privoxy
	$(ROMFSINST) -p +x /usr/bin/privoxy.sh
	$(ROMFSINST) -p +x /usr/bin/redirect.sh
	
