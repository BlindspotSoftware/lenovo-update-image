CAP_FILES := $(notdir $(wildcard firmware/*.cap))
FAT_FILES := $(patsubst %.cap,%.fat,$(CAP_FILES))
FAT_FILES += $(patsubst %.fat,%-capload.fat,$(FAT_FILES))
DISK_FILES := $(patsubst %.fat,%.disk,$(FAT_FILES))

DISK_SIZE_MB := 64

FAT_SIZE_MB := $(shell echo $$(( $(DISK_SIZE_MB) - 2 )))
FAT_SIZE_KB := $(shell echo $$(( $(FAT_SIZE_MB) * 1024 )))
FAT_START_MB := 1
FAT_END_MB := $(shell echo $$(( $(FAT_SIZE_MB) + 1 )))

all: disk

disk: $(DISK_FILES)

clean:
	rm -rf *.disk *.fat *.iso *.rootfs *.tmp

%.fat: assets/startup.nsh assets/EfiShell.efi assets/ShellFlash.efi
	@rm -f $@.tmp
	mkfs.vfat -C $@.tmp $(FAT_SIZE_KB)
	mmd -i $@.tmp ::EFI
	mmd -i $@.tmp ::EFI/BOOT
	mcopy -i $@.tmp assets/EfiShell.efi ::EFI/BOOT/BOOTX64.efi
	mcopy -i $@.tmp assets/ShellFlash.efi ::EFI/ShellFlash.efi
	mcopy -i $@.tmp $< ::EFI/BOOT/startup.nsh
	mcopy -i $@.tmp firmware/$(patsubst %-capload,%,$*).cap ::EFI/FIRMWARE.cap
	mv $@.tmp $@

# TODO: Is there a better way to merge this into the %.fat recipe?
%-capload.fat: assets/startup-capload.nsh assets/EfiShell.efi assets/ShellFlash.efi
	@rm -f $@.tmp
	mkfs.vfat -C $@.tmp $(FAT_SIZE_KB)
	mmd -i $@.tmp ::EFI
	mmd -i $@.tmp ::EFI/BOOT
	mcopy -i $@.tmp assets/EfiShell.efi ::EFI/BOOT/BOOTX64.efi
	mcopy -i $@.tmp assets/ShellFlash.efi ::EFI/ShellFlash.efi
	mcopy -i $@.tmp $< ::EFI/BOOT/startup.nsh
	mcopy -i $@.tmp firmware/$(patsubst %-capload,%,$*).cap ::EFI/FIRMWARE.cap
	mv $@.tmp $@

%.disk: %.fat
	dd if=/dev/zero of=$@.tmp bs=1M count=$(DISK_SIZE_MB)
	parted $@.tmp mklabel gpt
	parted $@.tmp mkpart primary fat32 $(FAT_START_MB)MiB $(FAT_END_MB)MiB
	parted $@.tmp set 1 esp on
	parted $@.tmp print
	dd if=$< of=$@.tmp bs=1M seek=1 conv=notrunc
	mv $@.tmp $@

.PHONY: all clean disk iso
#.PRECIOUS: $(FAT_FILES)
