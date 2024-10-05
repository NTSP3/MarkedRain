## Replacing Kernel

_9th of April, 2024: 8:31_
Modified: _15th of June, 2024: 9:23_
          _4th of October, 2024: Added patch files documentation_

Replacing the current Linux kernel of the MRain Operating System can he helpful if you are trying to install a modified kernel suited to your needs or just testing out new stuff. To do this, you need to copy your bzImage file to source/kernel.

# Building Kernel

To rebuild the kernel, you can use the configuration used to build the kernel of MRain, which is located in source/kernel/config.txt. You only need to do this if you want to keep the configuration of the current kernel and only modify some bits you want to.
If you want the kernel modifications made for use with the MarkedRain system, you would also need to apply the .patch files to the files in the kernel source directory.

1. Clone the linux repository to your local computer and extract it.

2. Copy the config file "config.txt" to your linux directory and replace the ".config" file with it.

3. Run 'patch <file-in-kernel-source> < <modded-file-patch>', here is an example:
    - Patch file is in 'source/kernel/source/init/main.c.patch'
    - File to be modified is 'src-kernel/init/main.c'
    - Command will be:

        patch src-kernel/init/main.c < source/kernel/source/init/main.c.patch

   Typically, the file to be modified in the kernel source directory is the bit following 'source/kernel' till (not including) '.patch'

4. Use "make menuconfig" to change what you want to change.

5. After saving the new file from menuconfig, use "make" on the directory where the kernel's 'Makefile' is located and then wait a while for it to compile. You can also use "make -j <cpu-cores>" to make it faster.

6. Copy your new bzImage file from "<linux>/arch/x86/bzImage" to "source/kernel/bzImage". You may overwrite the old file or rename it to save as a backup. When adding the new kernel, be sure to copy the ".config" file of your new kernel over the old "config.txt" file, it's just a good practice.

## X--- End of the file ---X
