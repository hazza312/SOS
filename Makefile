ARCH ?= x86_64
TARGET ?= pc
MODE ?= debug

# (cross-compiler) location
ifeq ($(ARCH), x86_64)
	GNAT_BIN := ~/opt/GNAT/2018/bin
endif

# gnat tools
GPRBUILD := $(GNAT_BIN)/gprbuild
BIND := $(GNAT_BIN)/gnatbind
COMPILE := $(GNAT_BIN)/gnat
PROJECT := SOS.gpr

# emulation tools
QEMU:=qemu-system-x86_64
QEMU_FLAGS:=

DEBUG_GUI:=ddd
DEBUG_GUI_FLAGS:=


# begin rules
autobuild:
	$(GPRBUILD) -gnatc -c -k  -d -P "$(PROJECT)"

# Clean the root project of all build products.
clean:
	gnatclean -P "$(PROJECT)"
	rm -rf dist/kernel dist/*.iso

# Check project sources for errors.
# Does not build executables.
analyze:
	$(GPRBUILD) -d  -gnatc -c -k  -P "$(PROJECT)" --compiler-subst=ada,$(GNAT_BIN)/gcc

# Build executables for all mains defined by the project.
build:
	$(GPRBUILD) -d -P "$(PROJECT)" -Xarch=$(ARCH) -Xmode=$(MODE)

# Clean, then build executables for all mains defined by the project.
rebuild: clean build

# Compile individual file.
compile_file:
	$(GPRBUILD) -d -ws -c -u -P "$(PROJECT)" "$(FILE)"

# Analyze individual file (no object code generated).
analyze_file:
	$(GPRBUILD) -d -q -c -gnatc -u -P "$(PROJECT)" "$(FILE)"
	
iso:	build
	cp dist/kernel dist/iso/boot/kernel
	grub-mkrescue -o dist/os.iso dist/iso
	
debug:	iso
	$(QEMU) -cdrom dist/os.iso -s &
	$(DEBUG_GUI) --eval-command="target remote localhost:1234" --symbols=dist/kernel 2> /dev/null 

run:	iso 
	$(QEMU) -cdrom dist/os.iso -s
	
	
