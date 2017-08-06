SRC_NAME=libsodium-1.0.13
DLSITE=https://download.libsodium.org/libsodium/releases

all: config_test
	$(MAKE) -C $(SRC_NAME)

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
	aclocal; \
	autoconf; \
	automake; \
	./configure \
		--prefix=$(STAGEDIR) \
		--disable-shared \
		--enable-static \
		--enable-minimal \
		--host=$(HOST_TARGET) \
		--build=$(HOST_BUILD) ; \
	)

clean:
	rm -rf $(SRC_NAME)
	rm -f config_done

install:
	$(MAKE) -C $(SRC_NAME) install DESTDIR=""

romfs:
#	cp -fP $(DESTDIR)/src/libsodium/lib*.la $(ROMFSDIR)/lib
#	cp -fP $(DESTDIR)/src/libsodium/.libs/lib*.a $(ROMFSDIR)/lib

