# "MarkedRain" Operating System

The "MarkedRain" is a new linux OS that uses buildroot with OpenRC as init. It is really easy to work with. There was an older system based on Os2020, but working with nothing proved difficult.

## Showcase


![Preview 1](media/preview1.png "MarkedRain OS preview 1")

![Preview 2](media/preview2.png "MarkedRain OS preview 2")

![Preview 3](media/preview3.png "MarkedRain OS preview 3")

## To-do Goals

- Add package manager
- Neat root directory (System/rootfs houses those stuff)
- Program files directory instead of bin sbin
- Windows command replicants "ren" "del" etc
- Graphical User Interface

## Compiling

Install dependencies for 'make' & 'menuconfig', then run "make menuconfig". Configure as per you desire, then you can either do "make" on the root directory, or go to "source/buildroot" and run menuconfig there, to configure its options, and then run "make" on the root directory, not on buildroot's directory.

View "docs/building.md" for other make options.