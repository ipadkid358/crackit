ARCHS=armv7 arm64

include $(THEOS)/makefiles/common.mk

TOOL_NAME = crackit
$(TOOL_NAME)_FILES = main.m
$(TOOL_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tool.mk
