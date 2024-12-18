//
// Text-based setup application for MarkedRain
// 26-11-2024 | 8:39pm
//

#include <errno.h>
#include <ncurses.h>
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

/* Definitions */
#define print(format, ...) wprint(stdscr, format, ##__VA_ARGS__)

/* Global variables */
// OSNAME = System name [eg. MarkedRain]
// OSVER = System version [eg. 1.0.0.33]
int rows, cols, tmp, tmp2;
WINDOW *status_bar; // Status bar window pointer

// Function 'help' displays help contents
void help() {
    printf("\n System setup");
    printf("\n -----------------");
    printf("\n\n setup <file>");
    printf("\n   +file = Path to a live bootup OpenRC log file");
    printf("\n\n Example: setup /var/log.txt\n\n");
    exit(EXIT_SUCCESS);
}

// status() edits the bottom bar - Expects the window to be named 'status_bar'
void status(const char *text) {
    // Clear status bar
    wclear(status_bar);

    // Display message
    wmove(status_bar, 0, 0);
    wprintw(status_bar, "%s", text);
    wrefresh(status_bar);
}

// Function 'wipe' clears the screen
void wipe() {
    // Clear status
    status("");
    // Get the second-last line
    int line = rows - 1;
    attron(COLOR_PAIR(3)); // Use color pair #3 for wiping

    // Wipe from row 4 till second-last line backwardly
    while (line > 3) {
        usleep(25000);
        move(line, 0);
        hline(' ', cols); // Fill it with spaces
        refresh();
        line--;
    }

    printw("   "); // Print three spaces
    attroff(COLOR_PAIR(3)); // Disable color pair #3
}

// Function 'wprint' prints text with a nice delay
void wprint(WINDOW *win, const char *format, ...) {
    va_list args;
    va_start(args, format);

    // Prepare formatted string
    char formatted_text[1024];
    vsnprintf(formatted_text, sizeof(formatted_text), format, args);
    va_end(args);
    formatted_text[strlen(formatted_text) + 1] = '\0'; // Increase length by 1 for space
    formatted_text[strlen(formatted_text)] = ' '; // Add a space to end (because the last character isn't printing)

    // Variables for processing text
    const char *text = formatted_text; // Use formatted text
    char buffer[1024] = {0};           // Buffer to hold a single word
    int ch_now = 0, col_now = 0, word_len = 0, max_columns = 0;

    // Get the number of columns for given window
    getmaxyx(win, tmp, max_columns);

    // Print text until a NULL character is reached
    while (text[ch_now] != '\0') {
        // Check for space or end of text
        if (text[ch_now] == ' ' || text[ch_now + 1] == '\0') {
            // Check if the word exceeds the available space + 2 for buffer
            if (col_now + word_len > max_columns - 5) {
                wprintw(win, "\n"); // Go to next line
                if (win == stdscr) printw("   "); // Print 3 spaces if we are printing to stdscr
                col_now = 3;          // Account for indentation
                wrefresh(win);        // Refresh window to display new text
                usleep(25000);        // Delay for animation
            }

            // Print the word and a space if it's not the end of the string
            wprintw(win, "%s", buffer);
            if (text[ch_now] == ' ') {
                wprintw(win, " ");
                col_now += 1; // Count the space
            }

            // Update column position and reset buffer
            col_now += word_len;
            memset(buffer, '\0', sizeof(buffer)); // Clear buffer
            word_len = 0;
        } else {
            // Add character to buffer
            buffer[word_len] = text[ch_now];
            word_len++;
        }

        ch_now++;

    }

    wrefresh(win); // Refresh window at the end
}

// This function displays the quit progress bar of width 60 characters (fixed)
// Functions: 0 = None, 1 = Reboot
void quit_screen(int function, int return_code) {
    // Create a new sub-window
    int row = rows - 12;
    int column = cols / 2;
    column = column - 37; // 37 is the half of Windows 2000 Quit progress width
    int height = 7;
    int width = 74;

    WINDOW *quit_win = newwin(height, width, row, column);
    refresh();
    wbkgd(quit_win, COLOR_PAIR(1)); // Set the color scheme to WHITE on BLUE
    nodelay(quit_win, TRUE); // Non-blocking input

    // Print our custom border because cool
    int i = 1;
    wprintw(quit_win, "╔"); // First corner

    // Print both left and right borders
    while (i < height - 1) {
        mvwprintw(quit_win, i, 0, "║");
        mvwprintw(quit_win, i, width - 1, "║");
        i++;
    }

    // Print the corners
    mvwprintw(quit_win, 0, width - 1, "╗");
    mvwprintw(quit_win, height - 1, 0, "╚");
    mvwprintw(quit_win, height - 1, width - 1, "╝");

    // Print both bottom and top borders animated
    i = 1;

    while (i < width - 1) {
        mvwprintw(quit_win, 0, i, "═");
        mvwprintw(quit_win, height - 1, i, "═");
        usleep(5000);
        wrefresh(quit_win); // Refresh the window
        i++;
    }

    // Print title
    wmove(quit_win, 0, 2);
    char *str = "Exit setup";

    for (int i = 0; i < strlen(str); i++) {
        wprintw(quit_win, "%c", str[i]);
        usleep(25000);
        wrefresh(quit_win);
    }

    // Create a sub-win inside to display progress bar
    int progress_height = 3;
    int progress_width = 62;
    int progress_starty = height - 4;
    int progress_startx = width / 2;
    progress_startx = progress_startx - 31;

    WINDOW *progress_win = derwin(quit_win, progress_height, progress_width, progress_starty, progress_startx);
    box(progress_win, 0, 0);
    wrefresh(progress_win);

    // Start printing progress bar
    int text_start_pos;

    if (function == 0) {
        status("  ENTER=Quit");
        text_start_pos = (width / 2) - 16; // 16 is the half of len of msg "Setup will exit in %% seconds..."
    } else if (function == 1) {
        status("  ENTER=Restart Computer");
        text_start_pos = (width / 2) - 21; // 21 is the half of len of msg "Your computer will reboot in %% seconds..."
    }

    init_pair(4, COLOR_RED, COLOR_BLUE); // Color pair for progress bar ( Red on Blue )
    wattron(progress_win, COLOR_PAIR(4)); // Enable the color pair
    wmove(progress_win, 1, 1);
    int progress = 0;
    int time_remaining = 15;

    while (progress < progress_width - 2 && time_remaining > 0) {
        // Print how many seconds are remaining
        if (function == 0) mvwprintw(quit_win, progress_starty - 1, text_start_pos, "Setup will exit in %d seconds... ", time_remaining);
        if (function == 1) mvwprintw(quit_win, progress_starty - 1, text_start_pos, "Your computer will reboot in %d seconds... ", time_remaining);
        wrefresh(quit_win);

        i = 0;

        while (i != 4) {
            usleep(250000);
            wprintw(progress_win, "█");
            wrefresh(progress_win);
            i++;
            progress++;

            // Check if the user pressed ENTER
            int key = wgetch(quit_win);

            if (key == '\n') {
                time_remaining = 1;
                break;
            }

        }

        time_remaining--;
        wrefresh(progress_win);
    }

    // Handle program closing
    if (function == 0) {
        endwin();
        exit(return_code);
    }

}

char *get_last_line(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        print("Error opening file '%s': %s", filename, strerror(errno));
        quit_screen(0, 1);
    }

    // Seek to the end of the file
    if (fseek(file, 0, SEEK_END) != 0) {
        print("Error seeking file '%s': %s", filename, strerror(errno));
        fclose(file);
        quit_screen(0, 1);
    }

    long file_size = ftell(file);
    if (file_size == -1) {
        print("Error determining file size of file '%s': %s", filename, strerror(errno));
        fclose(file);
        quit_screen(0, 1);
    }

    // Traverse backward to find the last newline
    long pos = file_size - 1;
    char ch;

    while (pos >= 0) {
        fseek(file, pos, SEEK_SET);
        fread(&ch, 1, 1, file);

        if (ch == '\n' && pos != file_size - 1) {
            pos++; // Move to the start of the last line
            break;
        }
        pos--;
    }

    // If no newline was found, start from the beginning
    if (pos < 0) pos = 0;

    // Read and print the last line
    fseek(file, pos, SEEK_SET);
    char *buffer = malloc(1024 * sizeof(char)); // Buffer of 1024 characters
    if (!fgets(buffer, 1024, file)) {
        strcpy(buffer, "Error reading the last line");
    }

    fclose(file);
    return buffer;
}

int main(int argc, char *argv[]) {
    /* Check if required arguments are passed */
    if (argc < 2) help();
    char *logfile = argv[1];

    /* Set locale to UTF-8 encoding */
    setlocale(LC_ALL, "");

    /* Initialize the window */
    initscr();
    cbreak();                               // Disable line buffering
    curs_set(0);                            // Hide cursor
    start_color();
    init_pair(1, COLOR_WHITE, COLOR_BLUE);  // Color pair of main window
    init_pair(2, COLOR_BLACK, COLOR_WHITE); // Color pair of status bar
    init_pair(3, COLOR_BLUE, COLOR_BLUE);   // Color pair for wiping
    wbkgd(stdscr, COLOR_PAIR(1));           // Default color (White on Blue)
    noecho();                               // Do not display input characters
    keypad(stdscr, TRUE);                   // Enable keypad for function key recognition
    getmaxyx(stdscr, rows, cols);           // Get the current resolution
    // Status bar
    status_bar = newwin(1, cols, rows - 1, 0); // Start new window at last row with width of columns
    wbkgd(status_bar, COLOR_PAIR(2));
    // Heading
    printw("\n %s %s", OSNAME, OSVER);
    getyx(stdscr, tmp2, tmp);
    printw("\n");
    for (tmp2 = 0; tmp2 <= tmp + 1; tmp2++) printw("═");
    printw("\n\n   ");
    refresh();

    /* Track the bootup log file */
    struct stat file_stat;
    time_t last_mod_time = 0;
    char *last_line;
    while (1) {
        if (stat(logfile, &file_stat) == -1) {
            print("Unable to open logfile '%s': %s", logfile, strerror(errno));
            quit_screen(0, 1);
        }

        // Check if the file's modification time has changed
        if (file_stat.st_mtime != last_mod_time) {
            last_mod_time = file_stat.st_mtime;
            last_line = get_last_line(logfile);
            if (strncmp(last_line, " * ", 3) == 0) status(last_line);
        }

        usleep(25000); // Wait for 25ms before checking again
    }

    status("fin");
    quit_screen(0, 0);

    /* Quit [dbg] */
    getch();
    endwin();

    return EXIT_SUCCESS;
}
