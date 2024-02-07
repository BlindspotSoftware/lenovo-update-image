fs0:\EFI\ShellFlash.efi /sn /sd /file fs0:\EFI\FIRMWARE.cap

# sleep 3 seconds
stall 3000000

# shutdown
reset -s
