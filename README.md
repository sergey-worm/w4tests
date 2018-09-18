# w4tests

Set of tests for WrmOS.

## Description

w4tests - collection of projects to test WrmOS:
* rand    - test rand() function;
* threads - test threads creation and deletion;
* malloc  - test malloc()/free() functions.

## How to

Build and run:

	test-rand-qemu-leon3:
		make -C ../wrmos build P=$(pwd)/cfg/prj/test-rand-qemu-leon3.prj \
			W=../wrmos B=../build/test-rand-qemu-leon3 E=$(pwd) -j
		qemu-system-sparc -M leon3_generic -display none -serial stdio \
			-kernel ../build/test-rand-qemu-leon3/ldr/bootloader.elf

	test-threads-qemu-leon3:
		make -C ../wrmos build P=$(pwd)/cfg/prj/test-threads-qemu-leon3.prj \
			W=../wrmos B=../build/test-threads-qemu-leon3 E=$(pwd) -j
		qemu-system-sparc -M leon3_generic -display none -serial stdio \
			-kernel ../build/test-threads-qemu-leon3/ldr/bootloader.elf

	test-malloc-qemu-leon3:
		make -C ../wrmos build P=$(pwd)/cfg/prj/test-malloc-qemu-leon3.prj \
			W=../wrmos B=../build/test-malloc-qemu-leon3 E=$(pwd) -j
		qemu-system-sparc -M leon3_generic -display none -serial stdio \
			-kernel ../build/test-malloc-qemu-leon3/ldr/bootloader.elf

## Contacts

Sergey Worm <sergey.worm@gmail.com>

