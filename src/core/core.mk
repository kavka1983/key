# Copyright 2017 jem@seethis.link
# Licensed under the MIT license (http://opensource.org/licenses/MIT)

CORE_PATH = core

BUILD_TIME_STAMP := $(shell python -c "import datetime;\
a = int(datetime.datetime.now().timestamp());\
res = ','.join(['0x{:x}'.format((a >> (i*8))&0xff) for i in range(8)]); \
print(res); \
")

GIT_HASH_FULL := $(shell git rev-parse HEAD)

GIT_HASH := $(shell python -c "import datetime;\
hash = '$(GIT_HASH_FULL)'; \
b = ['0x'+hash[i*2:(i+1)*2] for i in range(8)]; \
b.reverse(); \
res = ','.join(b); \
print(res); \
")

CDEFS += -DBUILD_TIME_STAMP="$(BUILD_TIME_STAMP)"
CDEFS += -DGIT_HASH="$(GIT_HASH)"

C_SRC += \
	$(CORE_PATH)/flash.c \
	$(CORE_PATH)/hardware.c \
	$(CORE_PATH)/layout.c \
	$(CORE_PATH)/nonce.c \
	$(CORE_PATH)/packet.c \
	$(CORE_PATH)/settings.c \
	$(CORE_PATH)/util.c \

# NRF24 module, defaults to 0
ifeq ($(USE_NRF24), 1)
    C_SRC += \
        $(CORE_PATH)/nrf24.c \
        $(CORE_PATH)/rf.c
    CDEFS += -DUSE_NRF24=1

    ifeq ($(USE_UNIFYING), 0)
        CDEFS += -DUSE_UNIFYING=0
    else
        C_SRC += $(CORE_PATH)/unifying.c
        CDEFS += -DUSE_UNIFYING=1
    endif
else
    CDEFS += -DUSE_NRF24=0
    CDEFS += -DUSE_UNIFYING=0
endif

# I2C module, defaults to 0
ifeq ($(USE_I2C), 1)
    CDEFS += -DUSE_I2C=1
else
    CDEFS += -DUSE_I2C=0
endif

# Scanner module, defaults to 1
ifeq ($(USE_SCANNER), 0)
    CDEFS += -DUSE_SCANNER=0
else
    C_SRC += \
        $(CORE_PATH)/matrix_scanner.c
    CDEFS += -DUSE_SCANNER=1
endif

# Hardware specific scan, defaults to 0
ifeq ($(USE_HARDWARE_SPECIFIC_SCAN), 1)
    CDEFS += -DUSE_HARDWARE_SPECIFIC_SCAN=1
else
    CDEFS += -DUSE_HARDWARE_SPECIFIC_SCAN=0
endif

# TODO: add compile time option to flag to enable/disable mouse support
ifeq ($(USE_USB), 1)
    C_SRC += \
        $(CORE_PATH)/mouse_report.c \

    CDEFS += -DHAS_MOUSE_SUPPORT
endif

# USB Keyboard module, defaults to 1
ifeq ($(USE_USB), 0)
    CDEFS += -DUSE_USB=0
else
    C_SRC += \
        $(CORE_PATH)/keyboard_report.c \
        $(CORE_PATH)/media_report.c \
        $(CORE_PATH)/vendor_report.c \
        $(CORE_PATH)/matrix_interpret.c \
        $(CORE_PATH)/mods.c \
        $(CORE_PATH)/usb_commands.c \
        $(CORE_PATH)/macro.c \
        $(CORE_PATH)/keycode.c
    CDEFS += -DUSE_USB=1
endif

# Bluetooth module, defaults to 0
ifeq ($(USE_BLUETOOTH), 1)
    CDEFS += -DUSE_BLUETOOTH=1
else
    CDEFS += -DUSE_BLUETOOTH=0
endif

ifeq ($(DEBUG_AES_KEY), 1)
    CDEFS += -DDEBUG_AES_KEY=1
else
    CDEFS += -DDEBUG_AES_KEY=0
endif
