# You may edit this makefile as long as you keep these original 
# target names defined.  You can change the recipes and/or add new targets.

# Not intended for manual invocation.
# Invoked if automatic builds are enabled.
# Analyzes only on those sources that have changed.
# Does not build executables.

GPRBUILD=gprbuild
PROJECT=SOS.gpr


autobuild:
	$(GPRBUILD) -gnatc -c -k  -d -P "$(PROJECT)"

# Clean the root project of all build products.
clean:
	gnatclean -P $(PROJECT)

# Clean root project and all imported projects too.
clean_tree:
	gnatclean -P $(PROJECT) -r

# Check project sources for errors.
# Does not build executables.
analyze:
	$(GPRBUILD) -d  -gnatc -c -k  -P "$(PROJECT)"

# Build executables for all mains defined by the project.
build:
	$(GPRBUILD) -d -P "$(PROJECT)"

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
	
	
