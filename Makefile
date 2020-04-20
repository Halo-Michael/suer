TARGET = suer
VERSION = 0.2.2
CC = xcrun -sdk iphoneos clang -arch armv7 -arch arm64 -arch arm64e -miphoneos-version-min=9.0
LDID = ldid

.PHONY: all clean

all: clean postinst suer
	mkdir com.michael.suer_$(VERSION)_iphoneos-arm
	mkdir com.michael.suer_$(VERSION)_iphoneos-arm/DEBIAN
	cp control com.michael.suer_$(VERSION)_iphoneos-arm/DEBIAN
	mv postinst com.michael.suer_$(VERSION)_iphoneos-arm/DEBIAN
	mkdir com.michael.suer_$(VERSION)_iphoneos-arm/usr
	mkdir com.michael.suer_$(VERSION)_iphoneos-arm/usr/bin
	mv suer/.theos/obj/suer com.michael.suer_$(VERSION)_iphoneos-arm/usr/bin
	dpkg -b com.michael.suer_$(VERSION)_iphoneos-arm

postinst: clean
	$(CC) postinst.c -o postinst
	strip postinst
	$(LDID) -Sentitlements.xml postinst

suer: clean
	sh make-suer.sh

clean:
	rm -rf com.michael.suer_* postinst suer/.theos
