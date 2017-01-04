.PHONY: deb clean

PWD := $(shell pwd)

all: deb

deb: clean
	@echo "Creating needed dirs..."
	@mkdir deb/usr
	@mkdir deb/usr/bin
	@mkdir deb/opt
	@mkdir deb/opt/twelve
	@echo "Preparing files for packaging..."
	@echo "#!/bin/bash" > deb/usr/bin/twelve
	@echo "APKTOOL=/opt/twelve/apktool.jar" >> deb/usr/bin/twelve
	@echo "SIGNAPK=/opt/twelve/signapk.jar" >> deb/usr/bin/twelve
	@echo "PUPLIC_KEY=/opt/twelve/testkey.x509.pem" >> deb/usr/bin/twelve
	@echo "PRIVATE_KEY=/opt/twelve/testkey.pk8" >> deb/usr/bin/twelve 
	@cat twelve >> deb/usr/bin/twelve
	@chmod 0755 deb/usr/bin/twelve
	@cp prebuilt/* deb/opt/twelve
	@cd $(PWD)/deb && md5deep -lr usr opt > DEBIAN/md5sums
	@echo "Creating debian package..."
	@fakeroot dpkg-deb --build deb twelve-`$(PWD)/deb/usr/bin/twelve -v`.deb 1>>/dev/null
	@echo "Package: `ls *.deb`"
	
clean:
	@rm -rf  deb/usr deb/opt *.deb deb/DEBIAN/md5sums dist
	