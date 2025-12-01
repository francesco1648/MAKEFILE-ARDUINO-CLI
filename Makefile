# =========================================
# Makefile compatibile con Linux / Raspberry Pi OS
# =========================================

# Basic settings
SKETCH_PATH = $(CURDIR)
SKETCH_NAME = $(notdir $(SKETCH_PATH))

# Board configuration
BOARD_FQBN ?= rp2040:rp2040:rpipico
OUTPUT_DIR = $(CURDIR)/build/output
BUILD_DIR = $(CURDIR)/build
LIBS_DIR = $(CURDIR)/lib
INCLUDE_DIR = $(CURDIR)/include

LIBRARY_PATHS = $(wildcard $(LIBS_DIR)/*/src)
LIBRARY_FLAGS = $(addprefix --library ,$(LIBRARY_PATHS))

INCLUDE_PATHS = $(INCLUDE_DIR) $(LIBRARY_PATHS)
CFLAGS += $(foreach dir, $(INCLUDE_PATHS), -I$(dir))
CXXFLAGS += $(foreach dir, $(INCLUDE_PATHS), -I$(dir))

SUCCESS_SYMBOL = "======================================== Compilation completed successfully ========================================="
ERROR_SYMBOL = "======================================== Compilation error! ========================================"
COMPILATION_SYMBOL = "======================================== Compilation in progress ========================================"

MODULE_DEFINE ?= "MK2_MOD1"
DESTINATION ?= /Volumes/RPI-RP2/


# Colored print macros for Linux
print_green = printf "\033[1;32m%s\033[0m\n" "$1"
print_red   = printf "\033[1;31m%s\033[0m\n" "$1"


# Detect Pico automatically (optional)
PORT ?= $(shell arduino-cli board list | grep -i "Raspberry Pi Pico" | awk '{print $$1}')

.DEFAULT:
	@echo "Invalid command: '$@'"
	@echo "Use 'make help' to see the list of available commands."

# Compilation
compile: clean_all
	@$(call print_green, $(COMPILATION_SYMBOL))
	@arduino-cli compile --fqbn $(BOARD_FQBN) --build-path $(BUILD_DIR) $(SKETCH_PATH) --output-dir $(OUTPUT_DIR) $(LIBRARY_FLAGS) \
		$(foreach dir, $(INCLUDE_PATHS), --build-property "compiler.cpp.extra_flags=-I$(dir) -D$(MODULE_DEFINE)") \
		&& $(call print_green, $(SUCCESS_SYMBOL)) || $(call print_red, $(ERROR_SYMBOL))


compile_fast:
	@arduino-cli compile --fqbn $(BOARD_FQBN) "$(SKETCH_PATH)"

compile_all:
	$(MAKE) compile BUILD_DIR=$(CURDIR)/build1 OUTPUT_DIR=$(CURDIR)/out_MK2_MOD1 MODULE_DEFINE="MK2_MOD1"
	$(MAKE) compile BUILD_DIR=$(CURDIR)/build2 OUTPUT_DIR=$(CURDIR)/out_MK2_MOD2 MODULE_DEFINE="MK2_MOD2"

# Upload .uf2 file (BOOTSEL mode)
upload_bootsel:
	@if [ -f "$(OUTPUT_DIR)/$(SKETCH_NAME).ino.uf2" ]; then \
		echo "Uploading .uf2 file to Raspberry Pi Pico..."; \
		cp "$(OUTPUT_DIR)/$(SKETCH_NAME).ino.uf2" "$(DESTINATION)"; \
		echo "Upload complete ✅"; \
	else \
		echo ".uf2 file not found. Run 'make compile' before uploading the code."; \
	fi

# Clean build folder
clean_all:
	@echo "Cleaning build folder..."     # stampa un messaggio
	@rm -rf "$(BUILD_DIR)"               # rimuove ricorsivamente la cartella di build (senza errori se non esiste)
	@echo "Build folder cleaned."        # conferma la pulizia

# List all available serial ports / boards
port:
	@echo "List of serial ports (boards) detected by the system:"
	@arduino-cli board list

# Upload via serial port (normal mode, not BOOTSEL)
upload:
	@if [ -z "$(PORT)" ]; then \
		echo "❌ Error: no port specified. Use: make upload PORT=/dev/ttyACM0"; \
	else \
		echo "Uploading to $(PORT)..."; \
		arduino-cli upload -p $(PORT) --fqbn $(BOARD_FQBN) --input-dir $(OUTPUT_DIR) --verbose; \
		echo "✅ Upload complete!"; \
	fi

# Serial monitor
monitor:
	arduino-cli monitor -p $(PORT) -c baudrate=115200

# Command guide
help:
	@echo "Available commands:"
	@echo "  make compile        - Compile the project"
	@echo "  make compile_fast   - Fast compilation without additional libraries"
	@echo "  make upload_bootsel - Copy .uf2 file to Pico (BOOTSEL mode)"
	@echo "  make clean_all      - Remove build files"
	@echo "  make monitor        - Open serial monitor"
	@echo "  make help           - Show this guide"