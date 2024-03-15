#include <getopt.h>
#include <locale.h>

#include "cp437.h"
#include "parser.h"
#include "sauce.h"
#include "util.h"

int main(int argc, char *argv[]) {
    // set locale and check for UTF-8 support
    char *locale;
    locale = setlocale(LC_ALL, "");

    if(strstr(locale, "UTF8") == NULL && strstr(locale, "UTF-8") == NULL) {
        fprintf(stderr, "Your terminal doesn't support UTF-8.");
        return 1;
    }

    if (argc < 2) {
        print_usage();
        exit(1);
    }

    // define rendering speed for ANSI Art
    unsigned int speed = 110;
    // define expected width of terminal (almost always 80)
    unsigned int width = 80;

    // parse cmd line options
    int opt = 0;
    while (opt != -1) {
        int option_index = 0;
        static struct option long_options[] = {
            {"cp437",   no_argument,       NULL,    0},
            {"help",    no_argument,       NULL,  'h'},
            {"sauce",   required_argument, NULL,    0},
            {"ssaver",  required_argument, NULL,  's'},
            {"speed",   required_argument, NULL,    0},
            {"width",   required_argument, NULL,    0},
            {NULL,      0,                 NULL,    0}
        };

        opt = getopt_long(argc, argv, ":s:h", long_options, &option_index);

        switch (opt) {
            // no args
            case -1:
                break;
            // long options are being used
            case 0:
                if (strcmp(long_options[option_index].name, "speed") == 0 && optarg) {
                    if (isArrayNumeric(optarg) == 0) {
                        speed = atoi(optarg);
                    } else {
                        fprintf(stderr, "Invalid speed specified\n");
                        exit(1);
                    }
                }
                if (strcmp(long_options[option_index].name, "width") == 0 && optarg) {
                    if (isArrayNumeric(optarg) == 0) {
                        width = atoi(optarg);
                    } else {
                        fprintf(stderr, "Invalid width specified\n");
                        exit(1);
                    }
                    if (width < 80) {
                      fprintf(stderr, "Invalid width, must be uint > 80\n");
                    }
                }
                if (strcmp(long_options[option_index].name, "sauce") == 0 && optarg) {
                    print_sauce_info(optarg);
                } else if (strcmp(long_options[option_index].name, "cp437") == 0) {
                    print_cp437();
                } else if (strcmp(long_options[option_index].name, "ssaver") == 0 && optarg) {
                    screensaver_mode(optarg, speed, width);
                }
                break;
            case 's':
                screensaver_mode(optarg, speed, width);
                break;
            case 'h':
                print_usage();
                exit(0);
                break;
            case '?':
                print_usage();
                exit(1);
                break;
            case ':':
                fprintf(stderr, "Missing filename or directory\n");
                break;
            default:
                print_usage();
                exit(1);
                break;
        }
    }

    // only one argument provided, try to render ansi art for that file
    if ((argc == 2 || argc == 4) && (optind == 1 || optind == 3)) {
        draw_ansi_art(argv[optind], speed, width);
        exit(0);
    }

    return 0;
}
