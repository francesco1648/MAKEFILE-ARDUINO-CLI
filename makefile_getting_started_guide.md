
# Guide to Using the Makefile for Raspberry Pi Pico / Pico W

This document explains how to **compile**, **upload**, and **monitor** a sketch on the **Raspberry Pi Pico** or **Raspberry Pi Pico W** using `make` and `arduino-cli`.
This allows you to manage everything from the terminal, without opening the Arduino IDE.

***

## Requirements

Make sure you have installed and configured:

- **Arduino CLI**

```bash
arduino-cli version
```


RPi Pico support:

```bash
arduino-cli core install rp2040:rp2040
```


## Project Structure

```bash
my_project/              ← main folder (SKETCH_PATH)
├── my_project.ino       ← main file
├── include/             ← any .h headers
├── lib/                 ← any custom libraries
│   ├── libA/
│   │   └── src/
│   │       ├── file.cpp
│   │       └── file.h
│   └── libB/
│       └── src/
│           ├── file.cpp
│           └── file.h
├── Makefile             ← this file
└── build/               ← (auto-created)
```


# Board Selection

In the Makefile, there is the variable:

```make
BOARD_FQBN ?= rp2040:rp2040:rpipico
```

Depending on your board, change it as follows:

- Raspberry Pi Pico --> rp2040:rp2040:rpipico
- Raspberry Pi Pico W --> rp2040:rp2040:rpipicow

To change it, open the Makefile and replace the line:

```bash
BOARD_FQBN ?= rp2040:rp2040:rpipico
```

with:

```bash
BOARD_FQBN ?= rp2040:rp2040:rpipicow
```


***

# Main Commands

Navigate to the project folder:

```bash
cd path/to/project
```


## Compile the Project

```bash
make compile
```

Compiles the sketch and generates `.bin` and `.uf2` files in `build/output`.

- Compile a specific variant:

```bash
make compile MODULE_DEFINE="MK2_MOD2"
```

- Fast compile (no extra libraries):

```bash
make compile_fast
```

- Compile all variants:

```bash
make compile_all
```

Compiles two versions (e.g., MK2_MOD1 and MK2_MOD2) in separate folders (`out_MK2_MOD1` and `out_MK2_MOD2`).

## Uploading the Program to the Pico

After compilation, you can upload the program in two ways:

### Method 1: Upload in BOOTSEL Mode

This uses the .uf2 file and does not require the serial port.

Procedure:

- Press and hold the BOOTSEL button (the only one on the board).
- Connect the Pico to the PC via USB while keeping BOOTSEL pressed.
- Release the button: the PC will detect the Pico as an external drive (e.g. E:).
- Open “This PC” and check the drive letter.
- Open the Makefile and look for this line:

```bash
DESTINATION ?= 'D:\'
```

! Replace D: with the correct letter (e.g., 'E:\').
You only need to do this once: the PC will always recognize the same drive.

Uploading:

```bash
make upload_bootsel
```

The .uf2 file will be automatically copied to the Pico and the program will start immediately.

For subsequent uploads:
Put the Pico in BOOTSEL (hold the button before connecting) and run:

```bash
make upload_bootsel
```


### Method 2: Upload via Serial Port (COM)

This uses the serial port of the Pico connected to the PC normally.

Procedure:

- Connect the Pico to the PC (do not press BOOTSEL).
- List available COM ports:

```bash
make port
```


A list such as the following will appear:

```bash
COM1
COM2 (Raspberry Pi Pico)
```

If your Pico is connected on COM2, run:

```bash
make upload PORT=COM2
```

The Makefile will use the compiled .bin file and upload it automatically.

## Open the Serial Monitor

To view Serial.print or Serial.println messages from your program:

Connect the Pico to the PC.

Find the COM port:

```bash
make port
```

Open the serial monitor by specifying the port:

```bash
make monitor PORT=COM2
```

The default baud rate is 115200.

## Clean Build Files

Clean the entire build folder:

```bash
make clean_all
```

Partial clean (output folder only):

```bash
make clean_output
```


## Complete List of Commands

| Command | Description |
| :-- | :-- |
| make compile | Compiles the project |
| make compile_fast | Fast compile |
| make compile_all | Compiles both versions (MK2_MOD1 and MK2_MOD2) |
| make upload | Upload via serial port (COM) |
| make upload_bootsel | Upload in BOOTSEL mode (USB drive) |
| make monitor | Opens the serial monitor |
| make port | Shows available COM ports |
| make auto_com_port | Automatically detects Pico's COM |
| make clean_all | Removes all build files |
| make clean_output | Removes only output files |
| make help | Shows command help |

## Useful Tips

After the first upload in BOOTSEL, you don’t need to change DESTINATION again.

If you have multiple Picos connected, always check which COM is assigned.

You can chain commands:

```bash
make compile && make upload PORT=COM2
```

⚠️ Troubleshooting


| Problem | Possible Cause | Solution |
| :-- | :-- | :-- |
| Pico not listed in COM ports | Driver not installed | Install Pico USB drivers or use **BOOTSEL** mode |
| `make upload` command fails | Incorrect COM port | Check with `make port` and update `PORT=COMx` |
| Pico not appearing as external drive (BOOTSEL) | BOOTSEL button not held | Hold BOOTSEL before connecting Pico |
| Compilation failed | Missing libraries | Make sure all libraries are in `lib/` or installed via `arduino-cli` |
| Serial monitor shows nothing | Wrong baud rate or port | Ensure both code and Makefile have **115200** and the correct port |