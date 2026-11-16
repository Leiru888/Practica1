SDK_ROOT = frdm-kl46z-sdk-main

CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

PROJECTFOLDER = $(SDK_ROOT)/boards/frdmkl46z/demo_apps

CPU = -mcpu=cortex-m0plus -mthumb

DEFINES = -DCPU_MKL46Z256VLL4

INCLUDES = \
	-I. \
	-I$(SDK_ROOT)/CMSIS/Include \
	-I$(SDK_ROOT)/devices/MKL46Z4 \
	-I$(SDK_ROOT)/devices/MKL46Z4/drivers

CFLAGS = $(CPU) \
	$(DEFINES) \
	$(INCLUDES) \
	-std=gnu11 \
	-O0 \
	-g3 \
	-Wall \
	-Wextra \
	-ffunction-sections \
	-fdata-sections \
	-fno-builtin

#

LDFLAGS = $(CPU) \
	-T linker.ld \
	-nostdlib \
	-Wl,--gc-sections \
	-Wl,-Map=$(TARGET).map

SOURCES =
TARGET =
OBJECTS =

all: $(TARGET).elf $(TARGET).bin

$(TARGET).elf: $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS) -lc -lnosys -lgcc
	$(SIZE) $@

%.o: %.c %.h
	$(CC) $(CFLAGS) -c $< -o $@

$(SDK_ROOT)/devices/MKL46Z4/drivers/%.o: $(SDK_ROOT)/devices/MKL46Z4/drivers/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

led_blinky: SOURCES = $(wildcard $(PROJECTFOLDER)/led_blinky/*.c)
led_blinky: TARGET = led_blinky
led_blinky: OBJECTS = $(SOURCES:.c=.o)
led_blinky: INCLUDES += $(PROJECTFOLDER)/led_blinky
led_blinky: all

hello_world:

flash_led: led_blinky

flash_hello: hello_world


clean:
	rm -f $(OBJECTS) $(TARGET).elf $(TARGET).bin $(TARGET).map

.PHONY: all clean flash_hello flash_led
