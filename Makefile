.PHONY: all clean clean_all cleanLibs objects proper proper_objects assertType


LAPTOP=0
CLUSTER=1

LOCATION=1#$(CLUSTER)
ARM_COMPILE=0

ifeq ($(LOCATION),$(LAPTOP))
HOME=/home/johannes
BINDIR=$(HOME)/workspace/fasthog/objs
ifeq ($(ARM_COMPILE),0)
$(info building on Laptop for Intel)
CUDA_INSTALL=/usr/local/cuda
else
$(info building on Laptop for ARM - Crosscompile)
$(error missing location of GL and glut librariries for ARM)
ARM_GLUT= #TODO
CUDA_INSTALL=/usr/local/cuda-arm
endif
else

ifeq ($(LOCATION),$(CLUSTER))
HOME=/home/inf3/bi83hybe
BINDIR=$(HOME)/fasthog/objs
ifeq ($(ARM_COMPILE),0)
$(info building on Cluster for Intel)
CUDA_INSTALL=/opt/cuda
else
$(info building on Cluster for ARM - Crosscompile)
$(error missing location of cuda librariries for ARM)
CUDA_INSTALL= #TODO
ARM_GLUT=/usr/arm-linux-gnueabihf/lib
endif
else

$(error unknown build location $(LOCATION))
endif
endif

CUDA_LIB=-L$(CUDA_INSTALL)/lib -L$(CUDA_INSTALL)/lib64
CUDA_SDK_DIR=$(HOME)/NVIDIA_GPU_Computing_SDK
NVCC_INC=-I$(CUDA_SDK_DIR)/C/common/inc -I$(CUDA_INSTALL)/include

NVCC=nvcc

ifeq ($(ARM_COMPILE),1)
CC=arm-linux-gnueabihf-g++
CC_FLAGS=
NVCC_FLAGS=-target-cpu-arch ARM -ccbin $(CC)
LD_FLAGS=-ccbin $(CC) $(CUDA_LIB) -L$(ARM_GLUT) -L$(CUDA_SDK_DIR)/C/lib -lcudart -lGL -lglut
else 
CC=g++
CC_FLAGS=
NVCC_FLAGS=
LD_FLAGS=$(CUDA_LIB) -L$(CUDA_SDK_DIR)/C/lib -lcudart -lGL -lglut
endif

export BINDIR
export CC
export CC_FLAGS
export NVCC_FLAGS
export LD_FLAGS
export NVCC
export NVCC_INC

all: assertType objects
	@$(MAKE) -C source link

proper: clean_all all

proper_objects: clean_all objects

ifeq ($(wildcard .build),)
last=-1
else
last=$(shell cat .build)
endif

ifeq ($(last),-1)
assertType:
	@echo $(ARM_COMPILE) > .build

else
ifeq ($(last),$(ARM_COMPILE))
assertType:
	@echo $(ARM_COMPILE) > .build

else
assertType:
	$(info *** architecture change detected ***)
	$(info ***      forcing cleanup ...     ***)
	@$(MAKE) -C source clean_all
	@$(MAKE) -C objs clean
	@echo $(ARM_COMPILE) > .build

endif
endif


objects:
	@$(MAKE) -C source objects

clean:
	@$(MAKE) -C source clean
	@$(MAKE) -C objs clean
	@rm -f .build

clean_all:
	@$(MAKE) -C source clean_all
	@$(MAKE) -C objs clean
	@rm -f .build

cleanLibs:
	@$(MAKE) -C source cleanLibs

