CAP_FILES := $(notdir $(wildcard firmware/*.cap))
FAT_FILES := $(patsubst %.cap,%.fat,$(CAP_FILES))
#ISO_FILES := $(patsubst %.cap,%.iso,$(CAP_FILES))
DISK_FILES := $(patsubst %.cap,%.disk,$(CAP_FILES))

DISK_SIZE_MB := 64

FAT_SIZE_MB := $(shell echo $$(( $(DISK_SIZE_MB) - 2 )))
FAT_SIZE_KB := $(shell echo $$(( $(FAT_SIZE_MB) * 1024 )))
FAT_START_MB := 1
FAT_END_MB := $(shell echo $$(( $(FAT_SIZE_MB) + 1 )))

all: disk

disk: $(DISK_FILES)

#iso: $(ISO_FILES)

clean:
	rm -rf *.disk *.fat *.iso *.rootfs *.tmp

%.fat: assets/EfiShell.efi assets/ShellFlash.efi assets/startup.nsh
	@rm -f $@.tmp
	mkfs.vfat -C $@.tmp $(FAT_SIZE_KB)
	mmd -i $@.tmp ::EFI
	mmd -i $@.tmp ::EFI/BOOT
	mcopy -i $@.tmp assets/EfiShell.efi ::EFI/BOOT/BOOTX64.efi
	mcopy -i $@.tmp assets/ShellFlash.efi ::EFI/ShellFlash.efi
	mcopy -i $@.tmp assets/startup.nsh ::EFI/BOOT/startup.nsh
	mcopy -i $@.tmp firmware/$*.cap ::EFI/FIRMWARE.cap
	mv $@.tmp $@

%.disk: %.fat
	dd if=/dev/zero of=$@.tmp bs=1M count=$(DISK_SIZE_MB)
	parted $@.tmp mklabel gpt
	parted $@.tmp mkpart primary fat32 $(FAT_START_MB)MiB $(FAT_END_MB)MiB
	parted $@.tmp set 1 esp on
	parted $@.tmp print
	dd if=$< of=$@.tmp bs=1M seek=1 conv=notrunc
	mv $@.tmp $@

#%.iso: %.fat
#	@rm -rf $@.rootfs
#	mkdir $@.rootfs
#	cp $< $@.rootfs/$(notdir $<)
#	xorriso -as mkisofs -R -f -no-emul-boot -e $(notdir $<) -o $@ $@.rootfs
#	rm -r $@.rootfs

.PHONY: all clean disk iso
#.PRECIOUS: $(FAT_FILES)
