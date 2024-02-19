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
  \EFI\ShellFlash.efi /sn /sd /capload /file \EFI\FIRMWARE.cap
else
  echo "ERROR: ShellFlash not found"
endif

# ShellFlash should not return if successful. So the update failed.
:failed
echo "ShellFlash Update failed!"

# Hold error output for 30 seconds for debugging purposes.
echo "Wait 30 seconds to shut down."
stall 30000000
reset -s
