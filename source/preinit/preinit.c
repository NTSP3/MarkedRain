//
// Preinit v2 file rewritten for MarkedRain Linux 0.0.3
// Timestamp 21-9-2024 | 12:58 pm
//

#include <errno.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <unistd.h>

#define MAX_LINES 1024  // Max lines to load into memory (.preinit)
#define MAX_LINE_LENGTH 4096  // Max char length per line (.preinit)

char val_temp[MAX_LINE_LENGTH + 128];
bool suppress_text = false;

void warn(const char *msg) {
    // Message formatting
    char buffer[strlen(msg) + 21];
    snprintf(buffer, sizeof(buffer), "Preinit: %s [Warning]\n", msg);
    printf("%s", buffer);
    return;

    // Use printf if we couldn't write to /dev/kmsg
    if (suppress_text) {
        printf("%s", buffer);
        return;
    }

    // Writing to /dev/kmsg shows messages as [<time>]<msg> & put them in logs
    int warn_fd = open("/dev/kmsg", O_WRONLY);

    if (warn_fd == -1) {
        perror("Preinit: Failed to open /dev/kmsg successfully");
        printf("Preinit: Messages from preinit will be printed using printf.\n");
        printf("%s", buffer);
        suppress_text = true;
        close(warn_fd);
        return;
    }

    if (write(warn_fd, buffer, strlen(buffer)) == -1) {
        perror("Preinit: Failed to write to /dev/kmsg successfully");
        printf("Preinit: Messages from preinit will be printed using printf.\n");
        suppress_text = true;
    }

    close(warn_fd);
}

int main() {
    FILE *file=fopen(".preinit", "r");

    if (!file) {
        warn("Cannot open .preinit (does file exist?), skipping.");
    } else {
        char *line[MAX_LINES]; // < -- stores each line as an array
        char buffer[MAX_LINE_LENGTH]; // < -- Temp to store current lines
        int line_number = 0;

        // Capture lines, put 'em in char[] as array!
        while (fgets(buffer, sizeof(buffer), file) != NULL && line_number < MAX_LINES) {
            // Remove \n from end of current line if found
            buffer[strcspn(buffer, "\n")] = '\0';

            // Copy the content into line[]
            line[line_number] = malloc(strlen(buffer) + 1);
            strcpy(line[line_number], buffer);

            line_number++;
        }

        // File needs to be closed!
        fclose(file);

        // Variable declarations for while loop
        char *cmd = (char *)malloc(MAX_LINE_LENGTH * sizeof(char));
        char *arg1 = (char *)malloc(MAX_LINE_LENGTH * sizeof(char));
        char *keyw = (char *)malloc(MAX_LINE_LENGTH * sizeof(char));
        char *arg2 = (char *)malloc(MAX_LINE_LENGTH * sizeof(char));
        bool quote = false;
        bool rem = false;
        int b = 0;
        int u = 0;
        int g = 0;
        int s = 0;

        // Execute stuff until end of array
        while (b < line_number) {
            // Reset for next line
            u = g = s = 0;
            quote = rem = false;
            memset(cmd, '\0', MAX_LINE_LENGTH);
            memset(arg1, '\0', MAX_LINE_LENGTH);
            memset(keyw, '\0', MAX_LINE_LENGTH);
            memset(arg2, '\0', MAX_LINE_LENGTH);

            // Skip spaces at start
            while (line[b][u] == ' ') u++;

            // Remove spaces from end
            s = strlen(line[b]);

            while (s > 0 && line[b][s - 1] == ' ') {
                line[b][s - 1] = '\0';
                s--;
            }

            s = 0;

            // Copy current set of characters into cmd, arg1, or arg2 until the end of the line
            while (line[b][u] != '\0') {
                if (quote || (!quote && line[b][u] != ' ')) {
                    if (line[b][u] == '"') quote = !quote;
                    if (s == 0) cmd[g++] = line[b][u];
                    else if (s == 1) arg1[g++] = line[b][u];
                    else if (s == 2) keyw[g++] = line[b][u];
                    else if (s == 3) arg2[g++] = line[b][u];
                    else if (s == 4) {
                        rem = true;
                        break;
                    }
                } else {
                    g = 0;
                    s++;
                }

                u++;
            }

            if (cmd[0] == '\0') {
                b++;
                continue;
            } else if ((rem && (strcmp(cmd, "mount") == 0 || strcmp(cmd, "link") == 0)) || (strcmp(cmd, "create") == 0 && arg2[0] != '\0')) {
                snprintf(val_temp, sizeof(val_temp), "Excessive number of arguments (maybe unquoted args?), skipping line %d", b + 1);
                warn(val_temp);
            } else if (strlen(arg1) < 3 || (strcmp(cmd, "create") != 0 && strlen(arg2) < 3)) {
                snprintf(val_temp, sizeof(val_temp), "Argument length is too little, skipping line %d", b + 1);
                warn(val_temp);
            } else if (arg1[0] != '"' || (strcmp(cmd, "create") != 0 && arg2[0] != '"')) {
                snprintf(val_temp, sizeof(val_temp), "Unquoted argument at line %d, skipping it", b + 1);
                warn(val_temp);
            } else if (strcmp(cmd, "create") != 0 && strcmp(keyw, "as") != 0) {
                snprintf(val_temp, sizeof(val_temp), "Keyword 'as' not found between %s and %s, skipping line %d", arg1, arg2, b + 1);
                warn(val_temp);
            } else {
                // Betray quotes
                memmove(arg1, arg1 + 1, strlen(arg1));
                arg1[strlen(arg1) - 1] = '\0';

                if (strcmp(cmd, "create") != 0) {
                    memmove(arg2, arg2 + 1, strlen(arg2));
                    arg2[strlen(arg2) - 1] = '\0';
                }

                if (strcmp(cmd, "mount") == 0) {
                    if (mount(arg1, arg2, NULL, MS_BIND, NULL) != 0) {
                        snprintf(val_temp, sizeof(val_temp), "Trying to mount '%s' as '%s' failed at line %d: %s", arg1, arg2, b + 1, strerror(errno));
                        warn(val_temp);
                    }

                } else if (strcmp(cmd, "link") == 0) {
                    if (symlink(arg1, arg2) != 0) {
                        snprintf(val_temp, sizeof(val_temp), "Creating symlink to '%s' as '%s' failed at line %d: %s", arg1, arg2, b + 1, strerror(errno));
                        warn(val_temp);
                    }

                } else if (strcmp(cmd, "create") == 0) {
                    if (mkdir(arg1, 0755) != 0) {
                        snprintf(val_temp, sizeof(val_temp), "Creating directory '%s' failed at line %d: %s", arg1, b + 1, strerror(errno));
                        warn(val_temp);
                    }

                } else {
                    snprintf(val_temp, sizeof(val_temp), "'%s' is not a valid command at line '%d'", cmd, b + 1);
                    warn(val_temp);
                }

            }

            b++;

        }

    }

    // Execute actual init program

    return EXIT_SUCCESS;
}
