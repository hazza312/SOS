TARGET ?= x86_64
ARCH ?= pc

# (cross-compiler) location
ifeq ($(TARGET), x86_64)
	GNAT_BIN = ~/opt/2018/GNAT
endif

# gnat tools
BIND = $(GNAT_BIN)/gnatbind
COMPILE = $(GNAT_BIN)/gnat
LINK = ld

# emulation tools
QEMU=qemu-system-i386
QEMU_FLAGS=

DEBUG_GUI=ddd
DEBUG_GUI_FLAGS=--eval-command="target remote localhost:1234" --symbols=dist/kernel


# begin rules
autobuild:
	$(GPRBUILD) -gnatc -c -k  -d -P "$(PROJECT)"

# Clean the root project of all build products.
clean:
	rm -rf obj/* dist/*

# Check project sources for errors.
# Does not build executables.
analyze:
	$(GPRBUILD) -d  -gnatc -c -k  -P "$(PROJECT)"

# Build executables for all mains defined by the project.
build:
	$(GPRBUILD) -d -v -P "$(PROJECT)"

# Clean, then build executables for all mains defined by the project.
rebuild: clean build

# Compile individual file.
compile_file:
	$(GPRBUILD) -d -ws -c -u -P "$(PROJECT)" "$(FILE)"

# Analyze individual file (no object code generated).
analyze_file:
	$(GPRBUILD) -d -q -c -gnatc -u -P "$(PROJECT)" "$(FILE)"
	
iso:	dist/kernel
	cp dist/kernel dist/iso/boot/kernel
	grub-mkrescue -o dist/os.iso dist/iso
	
debug-gui:	iso
	$(QEMU) -cdrom dist/os.iso -s &
	$(DEBUG_GUI) $(DEBUG_GUI_FLAGS) 2> /dev/null
	
	
