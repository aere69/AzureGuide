# *NEW* Step 3B Generalize the VM with Sysprep 
## *Note that running ​ sysprep with ​ generalize on an Azure VM makes it ​ unusable
## after. Do not generalize a VM that you want to keep. Instead, make a copy and generalize the copy.* 

1. Use RDP to connect to the new VM
2. If this was a real example, you’d want to set up any applications, code, files, etc that 
you want this image to contain
3. Run %windir%\system32\sysprep\sysprep.exe
4. Select OBOE and generalize
5. Select Shutdown after running
6. Click OK and disconnect from the VM
7. Wait for the machine to shut down

After all that in the portal create an image.