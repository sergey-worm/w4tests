
help:
	@echo "Use:"
	@echo "  make build   P=<path/*.prj> B=<build-dir> [ V=1 ]"
	@echo "  make clean   P=<path/*.prj> B=<build-dir> [ V=1 ]"
	@echo ""
	@echo "Examples:"
	@echo "  make clean   P=cfg/prj/hello-p3.prj B=../build/hello-p3"
	@echo ""

build:
	mkdir -p $B
	+make -C ../wrmos build P=$$(pwd)/$P B=$$(realpath $B) E=$$(pwd) V=$V
	+make ldp B=$B

clean:
	mkdir -p $B
	+make -C ../wrmos clean P=$$(pwd)/$P B=$$(realpath $B) E=$$(pwd) V=$V

rebuild:
	+make clean P=$P B=$B
	+make build P=$P B=$B

ldp:
	sparc-linux-objcopy  --target=srec $B/ldr/bootloader.elf $B/ldr/bootloader.srec
	~/Bin/Utils/srec2ldr $B/ldr/bootloader.srec $B/ldr/bootloader.ldr
	~/Bin/Utils/ldpmpack -i 5 -s 0x4300000 -O 0x13 $B/ldr/bootloader.ldr $B/ldr/bootloader.ldp

all-tests:
	#mkdir -p ../build
	make rebuild P=../wrmos/cfg/prj/hello-qemu-leon3.prj  B=../build/hello-qemu-leon3  -j V=1
#	make rebuild P=../wrmos/cfg/prj/hello-tsim-leon3.prj  B=../build/hello-tsim-leon3  -j V=1
#	make rebuild P=cfg/prj/hello-p3.prj                   B=../build/hello-p3          -j V=1
	make rebuild P=../wrmos/cfg/prj/hello-qemu-veca9.prj  B=../build/hello-qemu-veca9  -j V=1
	make rebuild P=../wrmos/cfg/prj/hello-qemu-x86.prj    B=../build/hello-qemu-x86    -j V=1
	make rebuild P=../wrmos/cfg/prj/hello-qemu-x86_64.prj B=../build/hello-qemu-x86_64 -j V=1
