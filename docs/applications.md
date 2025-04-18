## Adding applications

_18th of April, 2025: 09:10_

To add a new application to the OS structure, do the following:

# Steps for adding custom application

1. Create a new `*.mk` and a new `*.in` file with your application's name (without the extension) inside `source/applications/`.
2. In the `*.in` file, add a `string` config value named `app_dir_<your_app_name>` (omit the `.mk` suffix).
3. Set its default to `$(src_dir_apps)/<your_app_name>`.
4. In the `*.mk` file, define two recipes: `main_compile` and `main_install`.
5. Open `source/applications/applications.in` and append:

    ```
    source "$(src_dir_apps)/<your_app_name>.in"
    ```
6. Run `make menuconfig`, enable (or disable) your app, save, then execute `make`.

### Example

- Suppose you want to add 'my_app':
- Create `source/applications/my_app.mk` and `source/applications/my_app.in`
- Open the `my_app.in` file and add stuff like so: {

    config app_dir_my_app
        string "My awesome app"
        default "$(src_dir_apps)/my_app"
        help
            My awesome app is a utility to customize your awesome computer.

}

- Open the `my_app.mk` file and add stuff like so {

    define main_compile
        $(S) clone https://github.com/my_account/my_awesome_app.git "$(app_dir_my_app)"
        $(call sub, Compiling My awesome app)
        $(Q)$(MAKE) -C "$(app_dir_my_app)" $(OUT)
    endef

    define main_install
        $(call sub, Installing My awesome app)
        $(Q)$(MAKE) -C "$(app_dir_my_app)" install install_dir="$(bin_dir_tmp_squashfs)" $(OUT)
    endef

}

- Finally, open `source/applications/applications.in` file and append:

    ```
    source "$(src_dir_apps)/my_app.in"
    ```
- Now open menuconfig, make any changes you want and save, then run `make`.
- Tada, now your new app will get installed into MarkedRain OS!

# Notes

- If you don’t want to install an application, set `app_dir_<application name>` to empty in menuconfig.
- `main_compile` runs only when the app source changes.
- `main_install` runs on every build to install the app.
- Inside main_compile and main_install, please do not use '$(call Heading)' to display messages, else it will get ugly quickly.

## X--- End of the file ---X
