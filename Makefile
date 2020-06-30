export TARGET = iphone:clang:13.0:9.0
export ARCHS = armv7 arm64 arm64e
export VERSION = 0.3.0
export DEBUG = no
CC = xcrun -sdk ${THEOS}/sdks/iPhoneOS13.0.sdk clang -arch armv7 -arch arm64 -arch arm64e -miphoneos-version-min=9.0
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
	cd suer && make

clean:
	rm -rf com.michael.suer_* postinst suer/.theos
