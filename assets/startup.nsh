@echo -off

# find correct file system mapping
for %i in 0 1 2 3 4 5
  if exist fs%i:\EFI\ShellFlash.efi then
    set map fs%i
  endif
endfor

# execute ShellFlash if found
if exist %map%:\EFI\ShellFlash.efi then
  %map%:
  \EFI\ShellFlash.efi /sn /sd /file \EFI\FIRMWARE.cap
else
  echo "ERROR: ShellFlash not found"
endif

# ShellFlash should not return if successful. Update failed.
:failed

# sleep 10 seconds
stall 10000000

# shutdown
reset -s
