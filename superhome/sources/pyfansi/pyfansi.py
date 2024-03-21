#!python

"""
Author: Nodar Gogoberidze
Date: Feb-25-2024
LICENSE: MIT

"""

import sys

def print_logo():
    logo = \
        "   ·▄▄▄ ▄▄▄·  ▐ ▄ .▄▄ · ▪  \n" \
        "   ▐▄▄·▐█ ▀█ •█▌▐█▐█ ▀. ██ \n" \
        "   ██▪ ▄█▀▀█ ▐█▐▐▌▄▀▀▀█▄▐█·\n" \
        "   ██▌.▐█ ▪▐▌██▐█▌▐█▄▪▐█▐█▌\n" \
        "   ▀▀▀  ▀  ▀ ▀▀ █▪ ▀▀▀▀ ▀▀▀\n" \

    logo_color = "\033[38;5;162m"
    white = "\033[0;37m"
    print("%s%s" % (logo_color, logo), file=sys.stderr);
    print("\033[0m", file=sys.stderr) # reset terminal

if __name__ == "__main__":
    print_logo()

    # TODO: TEMPORARY EARLY TERMINATE
    exit(0)

    import select
    import argparse

    # n styling attributes available
    style_params = {
            "bold": ("-b", "--bold", "Use bold style"),
            "faint": ("-f", "--faint", "Use faint style"),
            "italics": ("-t", "--italics", "Use italics style"),
            "underline": ("-u", "--underline", "Use underline style"),
            "dunderline": ("-d", "--dunderline", "Use doubly underline style"),
            "slow_blink": ("-S", "--slow_blink", "Use slow blink style"),
            "fast_blink": ("-F", "--fast_blink", "Use fast blink style"),
            "invert": ("-r", "--invert", "Use invert style (reverse video)"),
            "hide": ("-x", "--hide", "Use hide style"),
            "strike": ("-s", "--strike", "Use strike style"),
   }

    parser = argparse.ArgumentParser(description="Color print utility")
    parser.add_argument("--print-3bit-fg", action="store_true", help="Print 3-bit foreground colors")
    parser.add_argument("--print-3bit-bg", action="store_true", help="Print 3-bit background colors")
    parser.add_argument("--print-8bit-fg", action="store_true", help="Print 8-bit foreground colors")
    parser.add_argument("--print-8bit-bg", action="store_true", help="Print 8-bit background colors")

    # populate the available n styling attributes
    for p in style_params.values():
        parser.add_argument(p[0], p[1], action="store_true", help=p[2])

    parser.add_argument('--print-hex', nargs=1, default=False, help="Print esc sequence for hex color\
            needs single hex string of 6 hex chars")
    parser.add_argument('--print-rgb', nargs=3, default=False, help="Print esc sequence for rgb colors\
            needs three r, g, b values")
    parser.add_argument('-l', '--literal', action="store_true", help="For usage with --print-hex or \
            --print-rgb; print the escape sequence literal")
    parser.add_argument('-n', '--normal', action="store_true", help="For usage with --print-hex or \
            --print-rgb; when --literal flag set, terminate with reset/normal escape sequence")
    parser.add_argument('-i', '--interactive', action="store_true", help="Interactive mode")

    args = parser.parse_args()
    # put args in dictionary instead of "namespace" object
    argsdict = vars(args)

    # n styling attributes, option names only
    optslist = style_params.keys()
    # if the cli arg is an n styling attribute
    # put it in the dictionary along with the boolean of if the flag was enabled
    printopts = {k:argsdict[k] for k in argsdict.keys() if k in optslist}

    # determine if stdin is available for reading
    # this is just the select syscall; man select
    # this method is preferable to sys.stdin.isatty becaus it works even in the
    # case of remote invocation (eg ssh)
    r,_,_ = select.select([sys.stdin],[],[],0)
    if r:
        # stdin is available for reading
        # ie sys.stdin.isatty() -> False
        stdin = r[0]
        lines = stdin.readlines()
        for l in lines:
            cli_dispatch(args, printopts, content=l.rstrip())
    elif args.interactive and (args.print_rgb or args.print_hex):
        # stdin is not available for reading
        # ie either sys.stdin.isatty() -> True or its locked up (eg top)
        # if we're in interactive mode, and a viable print option flag is enabled
        # the we loop on user input
        try:
            while True:
                line = sys.stdin.readline().rstrip()
                cli_dispatch(args, printopts, content=line)
        except KeyboardInterrupt:
            # abort on ^C
            sys.stdout.flush()
            exit(0)
    else:
        # stdin is not available for reading
        # ie either sys.stdin.isatty() -> True or its locked up (eg top)
        # either way, interactive mode is off, or the user put in a nonviable
        # print option, just run on cli args alone
        cli_dispatch(args, printopts)

