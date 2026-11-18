TARGET := iphone:clang:3.1.3:2.0
INSTALL_TARGET_PROCESSES = Facebook

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FacebookX

FacebookX_FILES = Tweak.x
FacebookX_CFLAGS = -fno-objc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
CFLAGS = -isystem /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/6.0/include