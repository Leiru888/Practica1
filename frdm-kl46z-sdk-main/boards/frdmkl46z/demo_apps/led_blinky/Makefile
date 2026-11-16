SDK_ROOT = ../../../..

CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

TARGET = practica_interrupciones

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

LDFLAGS = $(CPU) \
	-T linker.ld \
	-nostdlib \
	-Wl,--gc-sections \
	-Wl,-Map=$(TARGET).map

SOURCES = \
	$(wildcard *.c) \
	pin_mux.c \
	src/startup_mkl46z4.c \
	$(SDK_ROOT)/devices/MKL46Z4/drivers/fsl_gpio.c \
	$(SDK_ROOT)/devices/MKL46Z4/drivers/fsl_clock.c \
	$(SDK_ROOT)/devices/MKL46Z4/drivers/fsl_common.c \
	$(wildcard $(SDK_ROOT)/devices/MKL46Z4/utilities/*.c)

OBJECTS = $(SOURCES:.c=.o)

all: $(TARGET).elf $(TARGET).bin

$(TARGET).elf: $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS) -lc -lnosys -lgcc
	$(SIZE) $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(SDK_ROOT)/devices/MKL46Z4/drivers/%.o: $(SDK_ROOT)/devices/MKL46Z4/drivers/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -f $(OBJECTS) $(TARGET).elf $(TARGET).bin $(TARGET).map

.PHONY: all clean
