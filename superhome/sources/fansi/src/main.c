#include <getopt.h>
#include <locale.h>
#include <stdbool.h>

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
		// print cp437 charset
		bool do_cp437 = false;
    // print the sauce
    bool do_sauce = false;
    // go into screen save mode
    bool do_ssaver = false;


    // parse cmd line options
    int opt = 0;
    while (opt != -1) {
        int option_index = 0;
        static struct option long_options[] = {
            {"cp437",   no_argument,       NULL,    0},
            {"help",    no_argument,       NULL,  'h'},
            {"sauce",   no_argument,       NULL,    0},
            {"ssaver",  no_argument,       NULL,  's'},
            {"speed",   required_argument, NULL,    0},
            {"width",   required_argument, NULL,    0},
            {NULL,      0,                 NULL,    0}
        };

        opt = getopt_long(argc, argv, ":sh", long_options, &option_index);

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
                if (strcmp(long_options[option_index].name, "sauce") == 0) {
                    do_sauce = true;
                } else if (strcmp(long_options[option_index].name, "cp437") == 0) {
									  do_cp437 = true;
                } else if (strcmp(long_options[option_index].name, "ssaver") == 0) {
                    do_ssaver = true;
                }
                break;
            case 's':
                do_ssaver = true;
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

		if (do_cp437) {
		  	print_cp437();
    } else if (do_sauce) {
        print_sauce_info(argv[optind]);
    } else if (do_ssaver) {
        screensaver_mode(argv[optind], speed, width);
    } else {
        draw_ansi_art(argv[optind], speed, width);
    }

    exit(0);

    return 0;
}
