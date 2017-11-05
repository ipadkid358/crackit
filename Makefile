DEBUG = 0
ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

TOOL_NAME = crackit
crackit_FILES = main.c BJThreadedCounting.c
crackit_FRAMEWORKS = CoreFoundation
crackit_CFLAGS = -O0

include $(THEOS_MAKE_PATH)/tool.mk
