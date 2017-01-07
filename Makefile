.PHONY: deb clean

PWD := $(shell pwd)
INST_SIZE := $(shell du -shk deb | sed s/deb//)
PKG_VERSION := $(shell $(PWD)/twelve -v)
all: zip deb
	
zip: clean
	@echo "Making portable zip..."
	@mkdir -m 0755 dist
	@cp -a prebuilt dist
	@cat twelve | sed -e 's/^APKTOOL=.*/APKTOOL=prebuilt\/apktool.jar/' -e 's/^SIGNAPK=.*/SIGNAPK=prebuilt\/signapk.jar/' -e 's/^PUPLIC_KEY=.*/PUPLIC_KEY=prebuilt\/testkey.x509.pem/' -e 's/^PRIVATE_KEY=.*/PRIVATE_KEY=prebuilt\/testkey.pk8/' > dist/twelve
	@chmod 0755 dist/twelve
	@zip -5r twelve-`$(PWD)/dist/twelve -v`.zip dist
	@echo "Portable package: `ls *.zip`"


deb: pre-package
	@echo "Creating debian package..."
	@cat DEBIAN/control | sed -e 's/^Version:.*/Version: $(PKG_VERSION)/' -e 's/^Installed-Size:.*/Installed-Size: $(INST_SIZE)/' > deb/DEBIAN/control
	@fakeroot dpkg-deb --build deb twelve-`$(PWD)/deb/usr/bin/twelve -v`.deb 1>>/dev/null
	@echo "Package: `ls *.deb`"

pre-package: clean
	@echo "Creating needed dirs..."
	@mkdir deb
	@cp -a DEBIAN deb
	@mkdir deb/usr
	@mkdir deb/usr/bin
	@mkdir deb/usr/share
	@mkdir deb/usr/share/twelve
	@echo "Preparing files for packaging..."
	@cat twelve | sed -e 's/^APKTOOL=.*/APKTOOL=\/usr\/share\/twelve\/apktool.jar/' -e 's/^SIGNAPK=.*/SIGNAPK=\/usr\/share\/twelve\/signapk.jar/' -e 's/^PUPLIC_KEY=.*/PUPLIC_KEY=\/usr\/share\/twelve\/testkey.x509.pem/' -e 's/^PRIVATE_KEY=.*/PRIVATE_KEY=\/usr\/share\/twelve\/testkey.pk8/' > deb/usr/bin/twelve
	@chmod 0755 deb/usr/bin/twelve
	@cp prebuilt/* deb/usr/share/twelve
	@cd $(PWD)/deb && hashdeep -c md5 -lr usr > DEBIAN/md5sums
	
clean:
	@rm -rf  deb dist
	
clean-all: clean
	@rm -f *.deb *.zip
	