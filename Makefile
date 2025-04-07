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

SUCCESS_SYMBOL = " Compilation completed successfully! "
ERROR_SYMBOL = " Compilation error! "
COMPILATION_SYMBOL = " Compilation in progress... "

MODULE_DEFINE ?= "MK1_MOD1"
DESTINATION ?= 'E:\'

# OS detection and choose shell command
ifeq ($(OS),Windows_NT)
    PORT ?= $(shell arduino-cli board list | findstr "Raspberry Pi Pico" | for /f "tokens=1" %%a in ('more') do @echo %%a)
    DETECT_OS = Windows
    BOOTSEL_PATH = E:
    SHELL_CMD = pwsh -Command
    define print_green
        @pwsh -Command "Write-Host '$1' -ForegroundColor Green"
    endef

    define print_red
        @pwsh -Command "Write-Host '$1' -ForegroundColor Red"
    endef
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Darwin)
        PORT ?= /dev/ttyACM0
        DETECT_OS = macOS
        BOOTSEL_PATH = /Volumes/RPI-RP2
        SHELL_CMD = bash -c
        # Print messages in color (using the chosen shell)
        define print_green
            @echo "\033[32m$(1)\033[0m"
        endef

        define print_red
            @echo "\033[31m$(1)\033[0m"
        endef
    else
        # Main targets
        .PHONY: all compile upload clean help auto_com_port port

        PORT ?= /dev/ttyACM0
        DETECT_OS = Linux
        BOOTSEL_PATH = /media/$(USER)/RPI-RP2
        SHELL_CMD = bash -c
        # Print messages in color (using the chosen shell)
        define print_green
            @echo "\033[32m$(1)\033[0m"
        endef

        define print_red
            @echo "\033[31m$(1)\033[0m"
        endef
    endif
endif






all: clean compile upload

compile:
	$(call print_green, $(COMPILATION_SYMBOL))

	@arduino-cli compile --fqbn $(BOARD_FQBN) --build-path $(BUILD_DIR) $(SKETCH_PATH) --output-dir $(OUTPUT_DIR) $(LIBRARY_FLAGS) \
		$(foreach dir, $(INCLUDE_PATHS), --build-property "compiler.cpp.extra_flags=-I$(dir) -D$(MODULE_DEFINE)")




ifeq ($(DETECT_OS),Windows)
upload:
	@echo "Check that you have entered the correct COM port. The current COM port is: $(PORT)"
	@if exist "$(OUTPUT_DIR)/$(SKETCH_NAME).ino.bin" ( \
		echo "Uploading .bin file to Raspberry Pi Pico..." & \
		arduino-cli upload -p $(PORT) --fqbn $(BOARD_FQBN) --input-dir $(OUTPUT_DIR) $(SKETCH_NAME).ino.bin \
	) else ( \
		echo " .bin file not found. Run 'make compile' before uploading the code." \
	)
else
upload:
ifeq ($(PORT),)
	$(call print_red, "❌ Nessuna board Pico rilevata!")
else
	@$(SHELL_CMD) "if [ -f '$(OUTPUT_DIR)/$(SKETCH_NAME).ino.bin' ]; then \
		arduino-cli upload -p $(PORT) --fqbn $(BOARD_FQBN) --input-dir $(OUTPUT_DIR); \
	else \
		echo 'File .bin non trovato!' && exit 1; \
	fi"
endif
endif


ifeq ($(DETECT_OS),Windows)
upload_bootsel:
	@if exist "$(OUTPUT_DIR)/$(SKETCH_NAME).ino.uf2" ( \
		echo "Uploading .uf2 file to Raspberry Pi Pico..." && \
		powershell -Command "Copy-Item '$(OUTPUT_DIR)/$(SKETCH_NAME).ino.uf2' -Destination  $(DESTINATION)  -Force" || ( \
		    echo "Error while uploading, please make sure the pico is in BOOTSEL mode and is recognized as $(DESTINATION) storage drive. If it is recognized as another drive, please change the 'Destination' field of the upload_bootsel command"; \
		) \
	) else ( \
		echo ".uf2 file not found. Run 'make compile' before uploading the code." \
	)
else
upload_bootsel:
	@$(SHELL_CMD) "if [ -f '$(OUTPUT_DIR)/$(SKETCH_NAME).ino.uf2' ]; then \
		cp '$(OUTPUT_DIR)/$(SKETCH_NAME).ino.uf2' '$(BOOTSEL_PATH)/' && \
		echo 'File UF2 copiato in $(BOOTSEL_PATH)'; \
	else \
		echo 'File UF2 non trovato!' && exit 1; \
	fi"clean_all:
	@echo BUILD_DIR is: "$(BUILD_DIR)"

endif




ifeq ($(DETECT_OS),Windows)
clean:
	@echo BUILD_DIR is: "$(BUILD_DIR)"
	@if exist "$(BUILD_DIR)\output" ( \
		echo The build folder exists. & \
		rd /s /q "$(BUILD_DIR)" & \
		echo Build folder content removed. \
	) else ( \
		echo The output folder does not exist. \
	)
else
clean:
	@if [ -d "$(BUILD_DIR)/output" ]; then \
		$(SHELL_CMD) "rm -rf $(BUILD_DIR)" && \
		$(call print_green, 'Clean completed.'); \
	else \
		echo The output folder does not exist.; \
	fi
endif





monitor:
	@arduino-cli monitor -p $(PORT) -c baudrate=115200

help:
	@$(SHELL_CMD) "echo 'Comandi disponibili:'; \
		echo '  make all          - Compila e carica il progetto'; \
		echo '  make compile      - Compila il progetto'; \
		echo '  make upload       - Carica il firmware via USB'; \
		echo '  make upload-bootsel - Carica via modalità BOOTSEL'; \
		echo '  make monitor      - Avvia il monitor seriale'; \
		echo '  make clean        - Pulisci i file di build'; \
		echo '  make help         - Mostra questo aiuto'"

auto_com_port:
	@echo "The automatically detected COM port is: $(PORT)"

# List all available COM ports
port:
	@echo "List of COM ports detected by the system:"
	@arduino-cli board list
show_os:
	@echo "Detected OS: $(DETECT_OS)"
