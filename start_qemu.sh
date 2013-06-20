#!/bin/sh

# original settings, taken from "ps aux|grep qemu" after launching the VM from
# virt-manager
#
# qemu      7968 65.8 23.5 1492544 953672 ?      Sl   23:36   9:57
# /usr/bin/qemu-system-x86_64 -machine accel=kvm -name WindowsXP -S -machine
# pc-1.0,accel=kvm,usb=off -cpu
# Opteron_G2,+cr8legacy,+extapic,+cmp_legacy,+3dnow,+3dnowext,+fxsr_opt,+mmxext,+ht,+vme
# -m 768 -smp 2,sockets=1,cores=2,threads=1 -uuid
# b3932dcf-d95f-6a58-af90-25f857c95787 -no-user-config -nodefaults -chardev
# socket,id=charmonitor,path=/var/lib/libvirt/qemu/WindowsXP.monitor,server,nowait
# -mon chardev=charmonitor,id=monitor,mode=control -rtc base=localtime
# -no-shutdown -boot order=c,menu=on -device
# piix3-usb-uhci,id=usb,bus=pci.0,addr=0x1.0x2 -device
# virtio-serial-pci,id=virtio-serial0,bus=pci.0,addr=0x5 -drive
# file=/home/marcec/VBoxDrives/NewHardDisk1.img,if=none,id=drive-virtio-disk0,format=qcow2,cache=writethrough
# -device
# virtio-blk-pci,scsi=off,bus=pci.0,addr=0x7,drive=drive-virtio-disk0,id=virtio-disk0
# -drive
# file=/dev/vg0/KVMWinXP,if=none,id=drive-virtio-disk2,format=raw,cache=none
# -device
# virtio-blk-pci,scsi=off,bus=pci.0,addr=0x9,drive=drive-virtio-disk2,id=virtio-disk2
# -drive if=none,id=drive-ide0-1-0,readonly=on,format=raw -device
# ide-cd,bus=ide.1,unit=0,drive=drive-ide0-1-0,id=ide0-1-0 -netdev
# tap,fd=19,id=hostnet0 -device
# virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:4e:93:a5,bus=pci.0,addr=0x3
# -chardev pty,id=charserial0 -device isa-serial,chardev=charserial0,id=serial0
# -chardev spicevmc,id=charchannel0,name=vdagent -device
# virtserialport,bus=virtio-serial0.0,nr=1,chardev=charchannel0,id=channel0,name=com.redhat.spice.0
# -device usb-tablet,id=input0 -spice
# port=5900,addr=127.0.0.1,disable-ticketing,seamless-migration=on -k de -vga
# qxl -global qxl-vga.ram_size=67108864 -global qxl-vga.vram_size=67108864
# -device AC97,id=sound0,bus=pci.0,addr=0x4 -device
# virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x6
# marcec    9041  0.0  0.0  11856   888 pts/4    S+   23:52   0:00 grep --colour=auto qemu

####################
# main PC definition
####################

# cpu="Opteron_G2,+cr8legacy,+extapic,+cmp_legacy,+3dnow,+3dnowext,+fxsr_opt,+mmxext,+ht,+vme"
cpu="host"
mem="768"
smp="sockets=1,cores=2,threads=1"
# smp="2"
boot="order=c,menu=off"
machine="pc-1.0,accel=kvm,usb=off"
# machine="pc-q35-1.4,accel=kvm,usb=off"
layout="de"
pc_definition="-name WindowsXP \
    -machine $machine \
    -cpu $cpu \
    -m $mem \
    -smp $smp \
    -boot $boot \
    -k $layout"

# miscoptions="-uuid b3932dcf-d95f-6a58-af90-25f857c95787 \
    # -no-user-config \
    # -nodefaults \
    # -rtc base=localtime \
    # -no-shutdown"
miscoptions="-uuid b3932dcf-d95f-6a58-af90-25f857c95787 \
    -no-user-config \
    -rtc base=localtime"

#########
# devices
#########

disk0="-drive file=/dev/vg0/KVMWinXP,if=none,id=drive-virtio-disk0,format=raw,cache=none,aio=native \
    -device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x7,drive=drive-virtio-disk0,id=virtio-disk0"

disk1="-drive file=/home/marcec/VBoxDrives/NewHardDisk1.img,if=none,id=drive-virtio-disk2,format=qcow2,cache=writethrough,aio=native \
    -device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x9,drive=drive-virtio-disk2,id=virtio-disk2"

cdrom="-drive if=none,id=drive-ide0-1-0,readonly=on,format=raw \
    -device ide-cd,bus=ide.1,unit=0,drive=drive-ide0-1-0,id=ide0-1-0"

disks="$disk0 $disk1 $cdrom"

net="-netdev tap,script=no,downscript=no,ifname=kvm0,id=hostnet0 \
    -device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:4e:93:a5,bus=pci.0,addr=0x3"

sound="-device AC97,id=sound0,bus=pci.0,addr=0x4"

usb="-device piix3-usb-uhci,id=usb,bus=pci.0,addr=0x1.0x2"

mouse="-device usb-tablet,id=input0"

# misc=-chardev pty,id=charserial0 \
#     -device isa-serial,chardev=charserial0,id=serial0 \
#     -device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x6

#######################
# display related stuff
#######################

display="-display sdl"

vga_ram="67108864"
vga="-vga qxl \
    -global qxl-vga.ram_size=$vga_ram \
    -global qxl-vga.vram_size=$vga_ram"

spice="-device virtio-serial-pci,id=virtio-serial0,bus=pci.0,addr=0x5 \
    -chardev spicevmc,id=charchannel0,name=vdagent \
    -device virtserialport,bus=virtio-serial0.0,nr=1,chardev=charchannel0,id=channel0,name=com.redhat.spice.0 \
    -spice port=5900,addr=127.0.0.1,disable-ticketing,seamless-migration=on"

############
# start qemu
############

/usr/bin/qemu-system-x86_64 $pc_definition $miscoptions \
    $disks $net $sound $usb $mouse $display $vga $spice $misc
