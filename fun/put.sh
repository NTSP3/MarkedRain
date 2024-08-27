gcc -static -o source/preinit/preinit source/preinit/preinit.c
sudo mount bin/boot.iso bin/tst
sudo cp source/preinit/preinit bin/tst/System/base/init
sudo umount bin/tst
make run
