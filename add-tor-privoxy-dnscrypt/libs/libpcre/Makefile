# Update: https://sourceforge.net/projects/pcre/files/pcre/
SRC_NAME=pcre-8.41

all: config_test
	$(MAKE) -C $(SRC_NAME)

config_test:
	( if [ -f ./config_done ]; then \
		echo "the same configuration"; \
	else \
		make configure && touch config_done; \
	fi ) 

configure:
	( test -d $(SRC_NAME) || tar -xzf $(SRC_NAME).tar.gz; \
	cd $(SRC_NAME) ; \
	./configure \
		--prefix=$(STAGEDIR) \
		--disable-static \
		--enable-shared \
		--disable-cpp \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	rm -rf $(SRC_NAME)
	rm -f config_done

install:
	$(MAKE) -C $(SRC_NAME) install DESTDIR=""

romfs:
	cp -fP $(DESTDIR)/lib/libpcre.so* $(ROMFSDIR)/lib
	cp -fP $(DESTDIR)/lib/libpcreposix.so* $(ROMFSDIR)/lib

