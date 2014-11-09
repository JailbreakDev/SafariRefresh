THEOS_DEVICE_IP = iPad
TARGET := iphone:clang:8.1
ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = SafariRefresh
SafariRefresh_FILES = Tweak.xm
SafariRefresh_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSafari"
