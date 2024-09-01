changes

1. first if condition changed with shell file check
2. ',' in heading invokes like ', making Buildroot' replaced with ';'
3. 2nd if condition changed to 'ifeq ($(shell [ -f "$(src_dir_buildroot)/output/images/rootfs.tar" ] && [ -d "$(src_dir_buildroot)/output/build" ] && echo true),)'
4. 4th if condition 'ifneq' and 3rd if condition ending 'endif' changed to 'else ifneq'

big if change:

    ifeq ($(shell [ -f "$(src_dir_conf)/.errbr" ] && echo y), y)
    # file .errbr in src_dir_conf is found
	    $(call heading, sub, Error file found; making Buildroot)
    else
        ifeq ($(shell [ -f "$(src_dir_buildroot)/output/images/rootfs.tar" ] && [ -d "$(src_dir_buildroot)/output/build" ] && echo true),)
        # Either rootfs.tar or output/build doesn't exist
	        $(call heading, sub, rootfs.tar or BR output doesn't exist; making Buildroot)
        else
            ifneq ($(shell "$(src_dir_scripts)/get_var.sh" "buildroot_build_output" "$(src_dir_conf)/hashes.txt"),$(shell find "$(src_dir_buildroot)/output/build" -type d -printf '%T@' | md5sum | cut -d' ' -f1))
                ifneq ($(shell "$(src_dir_scripts)/get_var.sh" "buildroot" "$(src_dir_conf)/hashes.txt"),$(shell shasum "$(src_dir_buildroot)/.config" | cut -d ' ' -f 1))
                # Hash of .config and output/build is different
	                $(call heading, sub, Both .config and output/build changed; making Buildroot)
                else
                # Only hash of output/build is different
	                $(call heading, sub, output/build changed; making Buildroot)
                endif
            else ifneq ($(shell "$(src_dir_scripts)/get_var.sh" "buildroot" "$(src_dir_conf)/hashes.txt"),$(shell shasum "$(src_dir_buildroot)/.config" | cut -d ' ' -f 1))
            # Only hash of .config is different
	            $(call heading, sub, .config changed; making Buildroot)
            endif
        endif
    endif