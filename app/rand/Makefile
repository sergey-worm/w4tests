####################################################################################################
#
#  Makefile for user application.
#  External vars my be:
#    arch      - target arch
#    dbg       - debug flag
#    cfgdir    - path to dir that contents sys-config.h
#    blddir    - path to dir that will content build result
#    target    - target elf file name (hello.elf)
#
####################################################################################################

objs       := main.o
incflags   := -I$(cfgdir)
incflags   += -I$(wrmdir)/lib/l4/inc
incflags   += -I$(wrmdir)/lib/sys
incflags   += -I$(wrmdir)/lib/sys/$(arch)
incflags   += -I$(wrmdir)/lib/wrmos/inc
incflags   += -I$(wrmdir)/lib/wlibc/inc
incflags   += -I$(wrmdir)/lib/containers
baseflags  := -O2 -Wall -Werror
cxxflags   := -std=c++11 -fno-rtti -fno-exceptions
ldflags    :=
libs       := $(rtblddir)/lib/l4/libl4.a
libs       += $(rtblddir)/lib/wrmos/libwrmos.a
libs       += $(rtblddir)/lib/wlibc/libwlibc.a
libs       += $(rtblddir)/lib/wstdc++/libwstdc++.a
libs_ext   := $(realpath $(dir $(shell $(gccprefix)gcc -print-sysroot))/../../__$(arch)_uclibc-1.0.17_libm.a)

ifeq ($(dbg),1)
  baseflags += -DDEBUG
else
  baseflags += -DNDEBUG
endif

include $(wrmdir)/mk/base.mk
