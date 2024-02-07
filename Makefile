CAP_FILES := $(notdir $(wildcard firmware/*.cap))
FAT_FILES := $(patsubst %.cap,%.fat,$(CAP_FILES))
ISO_FILES := $(patsubst %.cap,%.iso,$(CAP_FILES))
TARGETS := $(ISO_FILES)

all: $(TARGETS)

clean:
	rm -rf *.fat *.iso *.rootfs *.tmp

%.fat: assets/EfiShell.efi assets/ShellFlash.efi assets/startup.nsh
	@rm -f $@.tmp
	mkfs.vfat -C $@.tmp $(shell echo $$(( 32 * 1024)))
	mmd -i $@.tmp ::EFI
	mmd -i $@.tmp ::EFI/BOOT
	mcopy -i $@.tmp assets/EfiShell.efi ::EFI/BOOT/BOOTX64.efi
	mcopy -i $@.tmp assets/ShellFlash.efi ::EFI/ShellFlash.efi
	mcopy -i $@.tmp assets/startup.nsh ::EFI/BOOT/startup.nsh
	mcopy -i $@.tmp firmware/$*.cap ::EFI/FIRMWARE.cap
	mv $@.tmp $@

%.iso: %.fat
	@rm -rf $@.rootfs
	mkdir $@.rootfs
	cp $< $@.rootfs/$(notdir $<)
	xorriso -as mkisofs -R -f -no-emul-boot -e $(notdir $<) -o $@ $@.rootfs
	rm -r $@.rootfs

.PHONY: all clean
#.PRECIOUS: $(FAT_FILES)
