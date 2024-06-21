## Building MarkedRain-dev

_9th of April, 2024: 8:44_
Modified: _15th of June, 2024: 9:23 - added 'make menuconfig', changed 'make dirs' keywords_
          _21st of June, 2024: 19:32 - removed 'make dirs'_

To compile the MRain OS, you can use the following commands:

# Commands

1. _"make menuconfig" - Provides a semi-graphical cli for configuring options_
2. _"make" - Compiles the OS._
3. _"make run" - Runs the OS in your VM._
4. _"make runs" - Compiles the OS and runs it in your VM._
5. _"make clean" - Deletes the bin directory and all of its sub directories._

The compiled OS would be located in "bin/<name>" where <name> is the name you specified in Makefile. If you are using the default configuration, it would be located as:

    bin/boot.iso

## X--- End of the file ---X