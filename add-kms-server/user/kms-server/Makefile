# https://forums.mydigitallife.info/threads/50234-Emulated-KMS-Servers-on-non-Windows-platforms
# prerequisites: sudo apt-get install p7zip-full
SRC_NAME=vlmcsd-1111-2017-06-17-Hotbird64
THISDIR = $(shell pwd)

all: config_test

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi )

configure:
	( test -d $(SRC_NAME) || 7z x -p2017 -o$(SRC_NAME) $(SRC_NAME).7z )

clean:
	if [ -f $(SRC_NAME)/Makefile ] ; then \
		$(MAKE) -C $(SRC_NAME) distclean ; \
	fi ; \
	rm -f config_done
	rm -rf install

romfs:
	$(ROMFSINST) -p +x -S $(THISDIR)/$(SRC_NAME)/binaries/Linux/mips/little-endian/static/vlmcsdmulti-mips32el-openwrt-uclibc-static /usr/bin/vlmcsdmulti
	$(ROMFSINST) -s vlmcsdmulti /usr/bin/vlmcsd
	$(ROMFSINST) -s vlmcsdmulti /usr/bin/vlmcs
