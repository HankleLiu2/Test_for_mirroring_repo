#################################################
# Configuration
##################################################
#Default build type
CONF=debug

#
# Tool names
#

#The name of the compiler to use
CXX = g++

#Name of the archiver used to create .a from sets of .o files
AR = ar

#
# Directories
#

#Directory for build temporaries
BUILD_DIR = build

#What directory contains the source files for the main exectuable?
EXE_SRC_DIR = main/src

#What directory contains the source files for the streets database static library?
LIB_MILESTONE0_SRC_DIR = libmilestone0/src

#
# Compiler flags
#

#What warning flags should be passed to the compiler?
WARN_FLAGS = -Wall

#What include flags should be passed to the compiler?
INCLUDE_FLAGS = -I$(LIB_MILESTONE0_SRC_DIR)

#What options to generate header dependancy files should be passed to the compiler?
DEP_FLAGS = -MMD -MP

#What extra flags to use in a debug build?
DEBUG_FLAGS = -g -O0

#What extra flags to use in a release build?
RELEASE_FLAGS = -O3

#Pick either debug or release build flags 
ifeq (debug, $(CONF))
DEBUG_RELEASE_FLAGS := $(DEBUG_FLAGS)
else ifeq (release, $(CONF))
DEBUG_RELEASE_FLAGS := $(RELEASE_FLAGS)
else
$(error Invalid value for CONF: '$(CONF)', must be 'debug' or 'release'. Try 'make help' for usage)
endif

#Collect all the options to give to the compiler
CFLAGS = $(DEP_FLAGS) $(WARN_FLAGS) $(DEBUG_RELEASE_FLAGS) $(INCLUDE_FLAGS) --std=c++11


#Flags for linking
# -L. tells the linker to also look in the current directory
LFLAGS = -L.

#
# Archiver flags
#

#Flags for the archiver (used to create static libraries)
ARFLAGS = rvs

#
#Output files
#

#Name of the primary executable
EXE=milestone0

#Name of the milestone 0  static library
LIB_MILESTONE0=libmilestone0.a

#
# Generate object file names from source file names
#

#Objects associated with the main executable
EXE_OBJ=$(patsubst %.cpp, $(BUILD_DIR)/%.o,$(wildcard $(EXE_SRC_DIR)/*.cpp))

#Objects associated with the streets database library
LIB_MILESTONE0_OBJ=$(patsubst %.cpp, $(BUILD_DIR)/%.o,$(wildcard $(LIB_MILESTONE0_SRC_DIR)/*.cpp))

#
# Depencancy files
#

#To capture dependancies on header files,
# we told the compiler to generate dependancy 
# files associated with each object file
#
#The ':.o=.d' syntax means replace each filename ending in .o with .d
# For example:
#   build/main/main.o would become build/main/main.d
DEP = $(EXE_OBJ:.o=.d) $(LIB_MILESTONE0_OBJ:.o=.d)

#Phony targets are always run (i.e. are always out of date)
.PHONY: clean

##################################################
# Make targets
##################################################

#The default target
# This is called when you type 'make' on the command line
all: $(EXE)

#Include header file dependancies generated by a
# previous compile
-include $(DEP)

#Link main executable
$(EXE): $(EXE_OBJ) $(LIB_MILESTONE0)
	$(CXX) $(CFLAGS) $^ $(LFLAGS) -o $@

#Assignment0 static library
$(LIB_MILESTONE0): $(LIB_MILESTONE0_OBJ)
	$(AR) $(ARFLAGS) $@ $^

#Note: % matches recursively between prefix and suffix
#      so %.cpp would match both src/a/a.cpp
#      and src/b/b.cpp
$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(EXE) $(LIB_MILESTONE0)

help:
	@echo "Makefile for ECE297 Milestone 0"
	@echo ""
	@echo "Usage: "
	@echo '    > make'
	@echo "        Call the default make target (all)."
	@echo "        This builds the project executable: '$(EXE)'."
	@echo "    > make clean"
	@echo "        Removes any generated files including exectuables,"
	@echo "        static libraries, and object files."
	@echo "    > make help"
	@echo "        Prints this help message."
	@echo ""
	@echo ""
	@echo "Configuration Variables: "
	@echo "    CONF={debug | release}"
	@echo "        Controls whether the build performs compiler optimizations"
	@echo "        to improve performance. The default is 'debug'."
	@echo ""
	@echo "        With CONF=debug debugging symbols are turned on and,"
	@echo "        compiler optimization is disabled ($(DEBUG_FLAGS))."
	@echo ""
	@echo "        With CONF=release compiler optimization is enabled ($(RELEASE_FLAGS))."
	@echo ""
	@echo "        You can configure specify this option on the command line."
	@echo "        To perform a debug build you can use: "
	@echo "            > make CONF=debug"
	@echo "        To perform a release build you can use: "
	@echo "            > make CONF=release"
