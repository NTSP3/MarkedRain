#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <syslog.h>
#include <sys/mount.h>

#define MAX_LINE_LENGTH 1024

void log_message(const char *message) {
    printf("%s\n", message);
    openlog(NULL, LOG_PID | LOG_CONS, LOG_USER);
    syslog(LOG_ERR, "%s", message);
    closelog();
}

void report_error(const char *program_name, const char *message, int line_number, const char *keyword) {
    char full_message[MAX_LINE_LENGTH];
    snprintf(full_message, sizeof(full_message), "%s : Error - Line %d: %s (%s)", program_name, line_number, keyword, message);
    log_message(full_message);
    exit(EXIT_FAILURE);
}

void report_warning(const char *program_name, const char *message, int line_number, const char *keyword) {
    char full_message[MAX_LINE_LENGTH];
    snprintf(full_message, sizeof(full_message), "%s : Warning - Line %d: %s (%s)", program_name, line_number, keyword, message);
    log_message(full_message);
}

void create_directories(const char *path, const char *program_name, int line_number, const char *keyword) {
    char temp[MAX_LINE_LENGTH];
    char *p = NULL;
    size_t len;

    snprintf(temp, sizeof(temp), "%s", path);
    len = strlen(temp);

    if (temp[len - 1] == '/') {
        temp[len - 1] = '\0';
    }

    for (p = temp + 1; *p; p++) {
        if (*p == '/') {
            *p = '\0';

            if (mkdir(temp, 0755) != 0 && errno != EEXIST) {
                report_warning(program_name, "Failed to create directory", line_number, keyword);
                return;
            }

            *p = '/';
        }
    }

    if (mkdir(temp, 0755) != 0 && errno != EEXIST) {
        report_warning(program_name, "Failed to create directory", line_number, keyword);
    }
}

void adjust_symlink_path(const char *source, const char *destination, char *adjusted_source) {
    int slash_count = 0;
    const char *ptr = destination;

    while (*ptr == '/') ptr++;  // Skip initial slashes

    while (*ptr != '\0') {
        if (*ptr == '/') {
            slash_count++;
        }
        ptr++;
    }

    for (int i = 0; i < slash_count; i++) {
        strcat(adjusted_source, "../");
    }

    strcat(adjusted_source, source);
}

void handle_mount_command(const char *source, const char *dest, const char *program_name, int line_number) {
    struct stat sb;

    // Ensure the source exists
    if (stat(source, &sb) != 0) {
        report_error(program_name, "Source path does not exist", line_number, "mount");
    }

    // Ensure the destination exists
    if (stat(dest, &sb) != 0) {
        report_error(program_name, "Destination path does not exist", line_number, "mount");
    }

    // Perform the bind mount
    if (mount(source, dest, NULL, MS_BIND, NULL) != 0) {
        report_error(program_name, "Error performing bind mount", line_number, "mount");
    }
}

int main(int argc, char *argv[]) {
    const char *program_name = argv[0];

    FILE *file = fopen(".preinit", "r");
    if (!file) {
        report_error(program_name, "Unable to open .preinit", 0, "N/A");
    }

    char line[MAX_LINE_LENGTH];
    int line_number = 0;
    while (fgets(line, sizeof(line), file)) {
        line_number++;

        char *newline = strchr(line, '\n');
        if (newline) {
            *newline = '\0';
        }

        char *ptr = line;
        while (*ptr == ' ' || *ptr == '\t') ptr++;

        if (strncmp(ptr, "link", 4) == 0) {
            ptr += 4;
            while (*ptr == ' ' || *ptr == '\t') ptr++;

            if (*ptr != '"') {
                report_error(program_name, "Source path not quoted", line_number, "link");
            }
            ptr++;

            char source[MAX_LINE_LENGTH];
            char *src_ptr = source;
            while (*ptr != '"' && *ptr != '\0') {
                *src_ptr++ = *ptr++;
            }
            *src_ptr = '\0';

            if (*ptr != '"') {
                report_error(program_name, "No closing quote for source path", line_number, "link");
            }
            ptr++;

            while (*ptr == ' ' || *ptr == '\t') ptr++;

            if (strncmp(ptr, "as", 2) == 0) {
                ptr += 2;
                while (*ptr == ' ' || *ptr == '\t') ptr++;

                if (*ptr == '\0' || *ptr == '\n') {
                    report_error(program_name, "No destination path specified after 'as'", line_number, "link");
                }

                if (*ptr != '"') {
                    report_error(program_name, "Destination path not quoted", line_number, "link");
                }
                ptr++;

                char dest[MAX_LINE_LENGTH];
                char *dest_ptr = dest;
                while (*ptr != '"' && *ptr != '\0') {
                    *dest_ptr++ = *ptr++;
                }
                *dest_ptr = '\0';

                if (*ptr != '"') {
                    report_error(program_name, "No closing quote for destination path", line_number, "link");
                }
                ptr++;

                // Check for additional paths after the first destination
                while (*ptr == ' ' || *ptr == '\t') ptr++;
                if (*ptr != '\0' && *ptr != '\n') {
                    report_error(program_name, "Multiple destinations not allowed", line_number, "link");
                }

                if (access(source, F_OK) != 0) {
                    report_warning(program_name, "Source path does not exist", line_number, "link");
                }

                char adjusted_source[MAX_LINE_LENGTH] = "";
                adjust_symlink_path(source, dest, adjusted_source);

                struct stat sb;
                if (lstat(dest, &sb) == 0) {
                    if (S_ISLNK(sb.st_mode)) {
                        report_warning(program_name, "Symlink already exists at destination path", line_number, "link");
                    } else {
                        report_warning(program_name, "File or directory already exists at destination path", line_number, "link");
                    }
                    continue;
                }

                if (symlink(adjusted_source, dest) == -1) {
                    report_error(program_name, "Error creating symlink", line_number, "link");
                }
            } else {
                char unknown_directive[MAX_LINE_LENGTH];
                snprintf(unknown_directive, sizeof(unknown_directive), "Unknown directive '%s' on line %d", ptr, line_number);
                report_error(program_name, unknown_directive, line_number, "link");
            }
        } else if (strncmp(ptr, "create", 6) == 0) {
            ptr += 6;
            while (*ptr == ' ' || *ptr == '\t') ptr++;

            if (*ptr == '\0') {
                report_warning(program_name, "No path specified after 'create'", line_number, "create");
                continue;
            }

            if (*ptr != '"') {
                report_error(program_name, "Directory path not quoted after 'create'", line_number, "create");
            }
            ptr++;

            char dir_path[MAX_LINE_LENGTH];
            char *dir_ptr = dir_path;
            while (*ptr != '"' && *ptr != '\0') {
                *dir_ptr++ = *ptr++;
            }
            *dir_ptr = '\0';

            if (*ptr != '"') {
                report_error(program_name, "No closing quote for directory path", line_number, "create");
            }

            create_directories(dir_path, program_name, line_number, "create");
        } else if (strncmp(ptr, "mount", 5) == 0) {
            ptr += 5;
            while (*ptr == ' ' || *ptr == '\t') ptr++;

            if (*ptr != '"') {
                report_error(program_name, "Source path not quoted", line_number, "mount");
            }
            ptr++;

            char source[MAX_LINE_LENGTH];
            char *src_ptr = source;
            while (*ptr != '"' && *ptr != '\0') {
                *src_ptr++ = *ptr++;
            }
            *src_ptr = '\0';

            if (*ptr != '"') {
                report_error(program_name, "No closing quote for source path", line_number, "mount");
            }
            ptr++;

            while (*ptr == ' ' || *ptr == '\t') ptr++;

            if (strncmp(ptr, "as", 2) != 0) {
                report_error(program_name, "Expected 'as' keyword", line_number, "mount");
            }
            ptr += 2;
            while (*ptr == ' ' || *ptr == '\t') ptr++;

            if (*ptr != '"') {
                report_error(program_name, "Destination path not quoted", line_number, "mount");
            }
            ptr++;

            char dest[MAX_LINE_LENGTH];
            char *dest_ptr = dest;
            while (*ptr != '"' && *ptr != '\0') {
                *dest_ptr++ = *ptr++;
            }
            *dest_ptr = '\0';

            if (*ptr != '"') {
                report_error(program_name, "No closing quote for destination path", line_number, "mount");
            }
            ptr++;

            // Check for additional paths after the first destination
            while (*ptr == ' ' || *ptr == '\t') ptr++;
            if (*ptr != '\0' && *ptr != '\n') {
                report_error(program_name, "Multiple destinations not allowed", line_number, "mount");
            }

            // Handle the mount command
            handle_mount_command(source, dest, program_name, line_number);
        } else {
            char unknown_directive[MAX_LINE_LENGTH];
            snprintf(unknown_directive, sizeof(unknown_directive), "Unknown directive '%s' on line %d", ptr, line_number);
            report_error(program_name, unknown_directive, line_number, "unknown");
        }
    }

    fclose(file);

    const char *init_apps[] = {
        "/sbin/init",
        "/etc/init",
        "/bin/init",
        "/bin/sh",
    };
    int num_apps = sizeof(init_apps) / sizeof(init_apps[0]);

    for (int i = 0; i < num_apps; i++) {
        char *argv[] = { (char *)init_apps[i], NULL };

        if (execvp(init_apps[i], argv) == -1) {
            report_warning(program_name, strerror(errno), line_number, "execvp");
        }
    }

    report_error(program_name, "None of the init applications could be executed", line_number, "execvp");
    return EXIT_FAILURE;
}
