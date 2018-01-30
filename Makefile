ifeq ($(MACOS),1)
    ARCHS = i386 x86_64
    TARGET = macosx:clang:10.12:latest
else
    ARCHS = armv7 arm64
    TARGET = iphone:clang:9.2:latest
endif

include $(THEOS)/makefiles/common.mk

TOOL_NAME = crackit
crackit_FILES = main.m
crackit_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tool.mk
