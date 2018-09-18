#!/bin/bash
####################################################################################################
#
#  Checks for WrmOS and its components.
#
####################################################################################################

blddir=/tmp/wrm-test/w4tests

# CONFIG
rand_sparc_build=1
rand_sparc_exec=2
rand_arm_veca9_build=3
rand_arm_veca9_exec=4
rand_arm_zynqa9_build=5
rand_arm_zynqa9_exec=6
rand_x86_build=7
rand_x86_exec=8
rand_x86_64_build=9
rand_x86_64_exec=10
threads_sparc_build=11
threads_sparc_exec=12
threads_arm_veca9_build=13
threads_arm_veca9_exec=14
threads_arm_zynqa9_build=15
threads_arm_zynqa9_exec=16
threads_x86_build=17
threads_x86_exec=18
threads_x86_64_build=19
threads_x86_64_exec=20
malloc_sparc_build=21
malloc_sparc_exec=22
malloc_arm_veca9_build=23
malloc_arm_veca9_exec=24
malloc_arm_zynqa9_build=25
malloc_arm_zynqa9_exec=26
malloc_x86_build=27
malloc_x86_exec=28
malloc_x86_64_build=29
malloc_x86_64_exec=30
result[$rand_sparc_build]=-
result[$rand_sparc_exec]=-
result[$rand_arm_veca9_build]=-
result[$rand_arm_veca9_exec]=-
result[$rand_arm_zynqa9_build]=-
result[$rand_arm_zynqa9_exec]=-
result[$rand_x86_build]=-
result[$rand_x86_exec]=-
result[$rand_x86_64_build]=-
result[$rand_x86_64_exec]=-
result[$threads_sparc_build]=-
result[$threads_sparc_exec]=-
result[$threads_arm_veca9_build]=-
result[$threads_arm_veca9_exec]=-
result[$threads_arm_zynqa9_build]=-
result[$threads_arm_zynqa9_exec]=-
result[$threads_x86_build]=-
result[$threads_x86_exec]=-
result[$threads_x86_64_build]=-
result[$threads_x86_64_exec]=-
result[$malloc_sparc_build]=-
result[$malloc_sparc_exec]=-
result[$malloc_arm_veca9_build]=-
result[$malloc_arm_veca9_exec]=-
result[$malloc_arm_zynqa9_build]=-
result[$malloc_arm_zynqa9_exec]=-
result[$malloc_x86_build]=-
result[$malloc_x86_exec]=-
result[$malloc_x86_64_build]=-
result[$malloc_x86_64_exec]=-

res_ok='\e[1;32m+\e[0m'
res_bad='\e[1;31m-\e[0m'

errors=0

function get_result
{
	if [ $rc == 0 ]; then echo $res_ok; else echo $res_bad; fi
}

function do_build
{
	id=$1
	prj=$2
	arch=$3
	brd=$4
	time make build P=cfg/prj/test-${prj}-qemu-${brd}.prj B=$blddir/$prj-qemu-${brd} -j
	rc=$?
	echo "Build:  rc=$rc."
	result[$id]=$(get_result $rc)
	if [ ${result[$id]} != $res_ok ]; then ((errors++)); fi
}

function do_exec
{
	id=$1
	prj=$2
	arch=$3
	brd=$4
	machine=$5

	qemu_args="-display none -serial stdio"
	qemu_args_x86="-serial stdio"
	run_qemu="qemu-system-$arch -M $machine $qemu_args -kernel $blddir/$prj-qemu-$brd/ldr/bootloader.elf"
	file=$blddir/$prj-qemu-$brd/ldr/bootloader.elf
	if [ $arch == x86 ]; then
		run_qemu="qemu-system-i386 $qemu_args_x86 -drive format=raw,file=$(realpath $blddir/$prj-qemu-$arch/ldr/bootloader.img)"
		file=$blddir/$prj-qemu-$brd/ldr/bootloader.img
	fi
	if [ $arch == x86_64 ]; then
		run_qemu="qemu-system-$arch $qemu_args_x86 -drive format=raw,file=$(realpath $blddir/$prj-qemu-$arch/ldr/bootloader.img)"
		file=$blddir/$prj-qemu-$brd/ldr/bootloader.img
	fi

	if [ -f $file ]; then
		if [ $prj == rand ]; then
			expect -c "\
				set timeout 30; \
				if { [catch {spawn $run_qemu} reason] } { \
					puts \"failed to spawn qemu: $reason\r\"; exit 1 }; \
				expect \"test passed.\r\" {} timeout { exit 1 }; \
				expect \"terminated.\r\"  {} timeout { exit 2 }; \
				exit 0"
			rc=$?
		else
		if [ $prj == threads ]; then
			expect -c "\
				set timeout 100; \
				if { [catch {spawn $run_qemu} reason] } { \
					puts \"failed to spawn qemu: $reason\r\"; exit 1 }; \
				expect \"test passed.\r\" {} timeout { exit 1 }; \
				expect \"terminated.\r\"  {} timeout { exit 2 }; \
				exit 0"
			rc=$?
		else
		if [ $prj == malloc ]; then
			expect -c "\
				set timeout 10; \
				if { [catch {spawn $run_qemu} reason] } { \
					puts \"failed to spawn qemu: $reason\r\"; exit 1 }; \
				expect \"test passed.\r\" {} timeout { exit 1 }; \
				expect \"terminated.\r\"  {} timeout { exit 2 }; \
				exit 0"
			rc=$?
		else
			rc=100  # unknown project
		fi
		fi
		fi
	else
		rc=200  # no exec file
	fi

	echo -e "\nExecute:  rc=$rc."
	result[$id]=$(get_result $rc)
	if [ ${result[$id]} != $res_ok ]; then ((errors++)); fi
}

function do_all
{
	rm -fr $blddir

	# cmd     id                         prj      arch    brd     machine

	do_build  $rand_sparc_build          rand     sparc   leon3   leon3_generic
	do_exec   $rand_sparc_exec           rand     sparc   leon3   leon3_generic
	#do_build  $rand_arm_veca9_build      rand     arm     veca9   vexpress-a9
	#do_exec   $rand_arm_veca9_exec       rand     arm     veca9   vexpress-a9
	#do_build  $rand_arm_zynqa9_build     rand     arm     zynqa9  xilinx-zynq-a9
	#do_exec   $rand_arm_zynqa9_exec      rand     arm     zynqa9  xilinx-zynq-a9
	#do_build  $rand_x86_build            rand     x86     x86     ""
	#do_exec   $rand_x86_exec             rand     x86     x86     ""
	#do_build  $rand_x86_64_build         rand     x86_64  x86_64  ""
	#do_exec   $rand_x86_64_exec          rand     x86_64  x86_64  ""

	do_build  $threads_sparc_build       threads  sparc   leon3   leon3_generic
	do_exec   $threads_sparc_exec        threads  sparc   leon3   leon3_generic
	#do_build  $threads_arm_veca9_build   threads  arm     veca9   vexpress-a9
	#do_exec   $threads_arm_veca9_exec    threads  arm     veca9   vexpress-a9
	#do_build  $threads_arm_zynqa9_build  threads  arm     zynqa9  xilinx-zynq-a9
	#do_exec   $threads_arm_zynqa9_exec   threads  arm     zynqa9  xilinx-zynq-a9
	#do_build  $threads_x86_build         threads  x86     x86     ""
	#do_exec   $threads_x86_exec          threads  x86     x86     ""
	#do_build  $threads_x86_64_build      threads  x86_64  x86_64  ""
	#do_exec   $threads_x86_64_exec       threads  x86_64  x86_64  ""

	do_build  $malloc_sparc_build       malloc  sparc   leon3   leon3_generic
	do_exec   $malloc_sparc_exec        malloc  sparc   leon3   leon3_generic
	#do_build  $malloc_arm_veca9_build   malloc  arm     veca9   vexpress-a9
	#do_exec   $malloc_arm_veca9_exec    malloc  arm     veca9   vexpress-a9
	#do_build  $malloc_arm_zynqa9_build  malloc  arm     zynqa9  xilinx-zynq-a9
	#do_exec   $malloc_arm_zynqa9_exec   malloc  arm     zynqa9  xilinx-zynq-a9
	#do_build  $malloc_x86_build         malloc  x86     x86     ""
	#do_exec   $malloc_x86_exec          malloc  x86     x86     ""
	#do_build  $malloc_x86_64_build      malloc  x86_64  x86_64  ""
	#do_exec   $malloc_x86_64_exec       malloc  x86_64  x86_64  ""
}

do_all

echo -e "-------------------------------------------------"
echo -e "  REPORT:"
echo -e "-------------------------------------------------"
echo -e "  project  arch    machine         build  execute"
echo -e "- - - - - - - - - - - - - - - - - - - - - - - - -"
echo -e "  rand     sparc   leon3_generic       ${result[$rand_sparc_build]}        ${result[$rand_sparc_exec]}"
echo -e "  rand     arm     vexpress-a9         ${result[$rand_arm_veca9_build]}        ${result[$rand_arm_veca9_exec]}"
echo -e "  rand     arm     xilinx-zynq-a9      ${result[$rand_arm_zynqa9_build]}        ${result[$rand_arm_zynqa9_exec]}"
echo -e "  rand     x86                         ${result[$rand_x86_build]}        ${result[$rand_x86_exec]}"
echo -e "  rand     x86_64                      ${result[$rand_x86_64_build]}        ${result[$rand_x86_64_exec]}"
echo -e "  threads  sparc   leon3_generic       ${result[$threads_sparc_build]}        ${result[$threads_sparc_exec]}"
echo -e "  threads  arm     vexpress-a9         ${result[$threads_arm_veca9_build]}        ${result[$threads_arm_veca9_exec]}"
echo -e "  threads  arm     xilinx-zynq-a9      ${result[$threads_arm_zynqa9_build]}        ${result[$threads_arm_zynqa9_exec]}"
echo -e "  threads  x86                         ${result[$threads_x86_build]}        ${result[$threads_x86_exec]}"
echo -e "  threads  x86_64                      ${result[$threads_x86_64_build]}        ${result[$threads_x86_64_exec]}"
echo -e "  malloc   sparc   leon3_generic       ${result[$malloc_sparc_build]}        ${result[$malloc_sparc_exec]}"
echo -e "  malloc   arm     vexpress-a9         ${result[$malloc_arm_veca9_build]}        ${result[$malloc_arm_veca9_exec]}"
echo -e "  malloc   arm     xilinx-zynq-a9      ${result[$malloc_arm_zynqa9_build]}        ${result[$malloc_arm_zynqa9_exec]}"
echo -e "  malloc   x86                         ${result[$malloc_x86_build]}        ${result[$malloc_x86_exec]}"
echo -e "  malloc   x86_64                      ${result[$malloc_x86_64_build]}        ${result[$malloc_x86_64_exec]}"

echo -e "errors:  $errors"
exit $errors
