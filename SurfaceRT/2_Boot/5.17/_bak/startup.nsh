fs0:
zImage dtb=tegra30-microsoft-surface-rt-efi.dtb root=/dev/sda2 cpuidle.off=1 net.ifnames=0 rootwait initrd=initrd.img

# shutdown if something went wrong
reset -s