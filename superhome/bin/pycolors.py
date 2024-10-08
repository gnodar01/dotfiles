#!python3

"""
Author: Nodar Gogoberidze
Date: Feb-25-2024
LICENSE: MIT

This program encodes ANSI escape sequences for terminal colors and such.
https://en.wikipedia.org/wiki/ANSI_escape_code

The more unified ANSI escape sequences are used instead of relying on
termcap, terminfo, tput, curses, ncurses, ...
https://en.wikipedia.org/wiki/Termcap
https://en.wikipedia.org/wiki/Terminfo
https://en.wikipedia.org/wiki/Tput
https://en.wikipedia.org/wiki/Curses_(programming_library)
https://en.wikipedia.org/wiki/Ncurses

Some notes on the escape codes:
  ASCII "escape" is octal `\\033`, hex `\\x1B` (or `^[`), decimal `27`.
  https://en.wikipedia.org/wiki/Escape_character#ASCII_escape_character
  https://en.wikipedia.org/wiki/ASCII#Character_set
  
  Unicode "escape" is `U+001B`, in python `"\\u001b"`.
  https://en.wikipedia.org/wiki/List_of_Unicode_characters#Control_codes
  
  Parser support will depend on its support of
  hexadecimal `\\x`, octal `\\0`, unicode `\\u` escapes.
  
  Some limited amount of parsers support the lesser used `\\e`
  commonly with parsers/languages that expect a lot of ANSI escaping to happen
  such as bash and other shells.
  Node.js, Lua, Python DO NOT support it, but PHP does.
  
  C supports `\\e` as well, and represents octal as `\\NNN` (N is octal num),
  hex as `\\xHH` (H is hex num), unicode code point `\\uHHHH`.
  https://en.wikipedia.org/wiki/Escape_sequences_in_C#Table_of_escape_sequences

  Finally, the reason `^[` maps to `0x1B`, ie escape, is because in a terminal
  (and sometimes in other programs) `^A` is `0x01`, `^B` is `0x02`, ...,
  `^Z` is `0x1A`, and next up is `^[` is `0x1B`.
  Vim for instance, can't differentiate between `ESC` and `^[` because it gets
  the same key code when either is pressed.
  https://bestasciitable.com/
  In the table above, you can see this mapping by looking at the third column,
  and tracing it to the same row on the first column whilst the `^` is pressed,
  ie `^<col_3,row_n> -> <col_1,row_n>`. It does so by switching the first bit
  (or 7th depending on Endiness) in the binary representation from `1` to `0`.
  Holding `^` just toggles this bit. Holding `SHIFT` just toggles the 2nd/6th
  bit mapping lowercase to equivilent uppercase on the same row.
  Under this scheme alone, we'd have `^<col_4,row_n> -> <col_2,row_n`, so
  `^i` (lowercase) would produce `)`, which is not useful. So instead if in
  `col_4`, hitting `^` implicitly adds `SHIFT`, mapping the lowercase to its
  uppercase, and mapping that to `col_1`. Therefore this is the mapping for
  column 4: `^<col_4,row_n> -> <col_1,row_n>`, so `^{` is actually `^SHIFT{`
  which is `^[` which again is `ESC`.

In this program, the escape code is followed by `[` which is the
Control Sequence Introducer (CSI), in order to perform *escape sequences*.
https://en.wikipedia.org/wiki/ANSI_escape_code#CSIsection
So we have `ESC [` or `^[ [` or whatever escape code encoding, followed by `[`
to start the sequence, followed by the sequence.

The escape sequence for "Select Graphic Rendition" (SGR) allows us to set
colors and styles of characters. It has the format of `CSI<n>m` where `<n>` is
a non-negative integer. Several attributes can be set in the same sequence,
using semicolon as a separater. So the format is really `CSI<n1>;<n2>;<...>m`.
`CSIm` is implicitly replaced with `CSI0m` which just means reset/normal.

NOTE: see here for some ANSI art fun:
      https://en.wikipedia.org/wiki/ANSI_art
"""


# === Exceptions ===
class OutOfRangeError(Exception):
    pass
class InvalidTypeError(Exception):
    pass
class ArgParseError(Exception):
    pass

# === UTILS ===


def check_num_range(num, lower=0, upper=0, return_as_str=False):
    assert type(upper) == int, f"upper must be int, is {type(upper)}"
    assert type(lower) == int, f"lower must be int, is {type(lowwer)}"

    if type(num) == str and num.isdigit():
        num = int(num)
    elif type(num) != int:
        raise InvalidTypeError("Must be an integer or castable as such")

    if num < lower or num > upper:
        raise OutOfRangeError(f"{len(upper-lower+1)} parameters supportable, indexed [{lower}-{upper}]")

    return str(num) if return_as_str else num


# === SEQUENCE START ==

# escape code
ESC = "\x1B"
# control squence introducer
CSI = "["
# sequence start
SS = f"{ESC}{CSI}"
SE = "m"

# === SGR ===

# sequence for turning off all attributes
NORMAL = "0"
RESET = f"{SS}{NORMAL}m"

# == SGR STYLES ==

# increased intensity
INTENSITY_BOLD = BOLD = "1"
# decreased instensity
INTENSITY_FAINT = FAINT = "2"
# not widely supported, sometimes inverse or blink
ITALICS = "3"
# style extension exist for Kitty, VTE, mintty, iTerm2 and Konsole
UNDERLINE = "4"
# < 150 times per minute
SLOW_BLINK = "5"
# > 150 times per minute; not widely supported
FAST_BLINK = "6"
# reverse video: swap fg and bg colors; inconsistent emulation
INVERT = "7"
# conceal; not widely supported
HIDE = "8"
# crossed-out; not supported in Terminal.app
STRIKE = "9"
# default font
PRIMARY_FONT = "10"
# 11-19; one of 9 alternative fonts
ALT_FONT_FN = lambda num: str(11 + check_num_range(num, 0, 8))
# Fraktur; rarely supported
GOTHIC = "20"
# doubly underlined, or not bold depending on the terminal
DUNDERLINE = DOUBLE_UNDERLINE = "21"
# neither bold nor faint
INTENSITY_OFF = "22"
# neither italic nor blackletter
ITALIC_OFF = "23"
# neither singly nor doubly underlined
UNDERLINE_OFF = "24"
# turn off slow/fast blinking
BLINK_OFF = "25"
# not really used on terminals
# PROPORTIONAL_SPACING = "26"
# not inverted; reverse video off
INVERT_OFF = "27"
# not concealed
HIDE_OFF = "28"
# not crossed out
STRIKE_OFF = "29"
# 30-37; set foreground color to one of the 8 primary/standard colors (3-bit)
# can use one of the 8 primary color constants defined below
FG_3BIT_FN = FG_PRIMARY_FN = lambda num: str(30 + check_num_range(num, 0, 7))
# bold varients of 30-37, ie 1;30 - 1;37
# these were the original "bright" FG values before 90-97 were introduced
# and now are differentiated (look different), at least in iTerm2 and Terminal.app
FG_BOLD_3BIT_FN = FG_BOLD_PRIMARY_FN = lambda num: ';'.join((BOLD, FG_3BIT_FN(num)))
# 38;5;n (38:5:<n> works too)
# for 8 bit (256 colors) selection:
#   [0-7]: standard colors (as in [30-37])
#   [8-15]: high intensity colors (as in [90-97])
#   [16-231]: 6 x 6 x 6 cube (216 colors): 16 + 36 x r + 6 x g + b (0 <= r, g, b <= 5)
#   [232-255]: grayscale from dark to light in 24 steps
FG_8BIT_FN = lambda num: f"38;5;{check_num_range(num, 0, 255)}"
# another way to set foreground to one of the 8 primary colors
# note: identical inputs to and color result of FT_3BIT_FN / FT_PRIMARY_FN
FG_8BIT_PRIMARY_FN = lambda num: FG_8BIT_FN(check_num_range(num, 0, 7))
# another way to set foreground to one of the high-intensity colors
# note: the input is expected to match values of one of the 8 primary color
#       constants defined below, eg 1 for bright red, which is then "brought up"
#       to its bright equivalent value; if you want to use the exact numerical
#       value expected by 38;5;<n> for a bright value, eg 9 for bright red,
#       just use FG_8BIT_FN directly or alternatively FG_BRIGHT_3BIT_FN
FG_8BIT_BRIGHT_FN = lambda num: FG_8BIT_FN(check_num_range(num+8, 8, 15))
# another way to set foreground to one of the 24 dark to light greyscale colors
# note: the input is expected to be [0 - 23] which is then "brought up" to the
#       greyscale value expected by the sequence code; if you want to use the
#       exact numerical value expected by 38;5;<n> for a greyscale value,
#       eg 232 for black (darkest grey), just use FG_8BIT_FN directly
FG_8BIT_GREY_FN = lambda num: FG_8BIT_FN(check_num_range(num+232, 232, 255))
# 38;2;r;g;b (38:2:r:g:b works too)
# "newer" support for "true color" graphic cards (see $COLORTERM)
# for 24 bit (16,777,216 colors) selection
# or for older terminals, more limited 16 bit (65,536 colors)
# Xterm, KDE's Konsole, iTerm, libvte family like GNOME Terminal all suport 24
FG_24BIT_FN = lambda r,g,b: f"38;2;{check_num_range(r, 0, 255)};{check_num_range(g, 0, 255)};{check_num_range(b, 0, 255)}"
# default foreground color
FG_OFF = "39"
# 40-47; set background color to one of the 8 primary/standard colors (3-bit)
# can use one of the 8 primary color constants defined below
BG_3BIT_FN = BG_PRIMARY_FN = lambda num: str(40 + check_num_range(num, 0, 7))
# bold varients of 40-47; ie 1;40 - 1;47
# these were the original "bright" BG values before 100-107 were introduced
# and now are differentiated (look different), at least in iTerm2 and Terminal.app
BG_BOLD_3BIT_FN = BG_BOLD_PRIMARY_FN = lambda num: ';'.join((BOLD, BG_3BIT_FN(num)))
# 48;5;n (48:5:n works too)
# for 8 bit (256 color) selection:
#   [0-7]: standard colors (as in [40-47])
#   [8-15]: high intensity colors (as in [100-107])
#   [16-231]: 6 x 6 x 6 cube (216 colors): 16 + 36 x r + 6 x g + b (0 <= r, g, b <= 5)
#   [232-255]: grayscale from dark to light in 24 steps
BG_8BIT_FN = lambda num: f"48;5;{check_num_range(num, 0, 255)}"
# another way to set foreground to one of the 8 primary colors
# note: identical inputs to and color result of FT_3BIT_FN / FT_PRIMARY_FN
BG_8BIT_PRIMARY_FN = lambda num: BG_8BIT_FN(check_num_range(num, 0, 7))
# another way to set background to one of the high-intensity colors
# note: the input is expected to match values of one of the 8 primary color
#       constants defined below, eg 1 for bright red, which is then "brought up"
#       to its bright equivalent value; if you want to use the exact numerical
#       value expected by 48;5;<n> for a bright value, eg 9 for bright red,
#       just use BG_8BIT_FN directly or alternatively BG_BRIGHT_3BIT_FN
BG_8BIT_BRIGHT_FN = lambda num: BG_8BIT_FN(check_num_range(num+8, 8, 15))
# another way to set background to one of the 24 dark to light greyscale colors
# note: the input is expected to be [0 - 23] which is then "brought up" to the
#       greyscale value expected by the sequence code; if you want to use the
#       exact numerical value expected by 48;5;<n> for a greyscale value,
#       eg 232 for black (darkest grey), just use BG_8BIT_FN directly
BG_8BIT_GREY_FN = lambda num: BG_8BIT_FN(check_num_range(num+232, 232, 255))
# 48;2;r;g;b (48:2:r:g:b works too)
# "newer" support for "true color" graphic cards (see $COLORTERM)
# for 24 bit (16,777,216 colors) selection
# or for older terminals, more limited 16 bit (65,536 colors)
# Xterm, KDE's Konsole, iTerm, libvte family like GNOME Terminal all suport 24
BG_24BIT_FN = lambda r,g,b: f"48;2;{check_num_range(r, 0, 255)};{check_num_range(g, 0, 255)};{check_num_range(b, 0, 255)}"
# default background color
BG_OFF = "49"
# complements 26, which is rarely supported
# PROPORTIONAL_SPACING_OFF = "50"
# line on top; not supported in Terminal.app
OVERLINE = "53"
# disable line on top
OVERLINE_OFF = "55"
# set underline color; has extra parameter
# not in standard; implemented in Kitty, VTE, mintty, and iTerm2
# for 8 bit (256 color) selection:
#   [0-7]: standard colors (as in [30-37] or [40-47])
#   [8-15]: high intensity colors (as in [90-97] or [100-107])
#   [16-231]: 6 x 6 x 6 cube (216 colors): 16 + 36 x r + 6 x g + b (0 <= r, g, b <= 5)
#   [232-255]: grayscale from dark to light in 24 steps
UNDERLINE_8BIT_FN = lambda num: f"58;5;{check_num_range(num, 0, 255)}"
# default underline color
# not in standard; implemented in Kitty, VTE, mintty, and iTerm2
UNDERLINE_COLOR_OFF = "59"
# 90-97; set foreground color to the bright version of one of the
# 8 primary/standard colors (3-bit)
# can use one of the 8 primary color constants defined below
FG_BRIGHT_3BIT_FN = FG_BRIGHT_PRIMARY_FN = lambda num: str(90 + check_num_range(num, 0, 7))
# 100-107; set background color to the bright (high intensity) version of one of the
# 8 primary/standard colors (3-bit)
# can use one of the 8 primary color constants defined below
BG_BRIGHT_3BIT_FN = BG_BRIGHT_PRIMARY_FN = lambda num: str(100 + check_num_range(num, 0, 7))

# == SGR COLORS ==

# -- 8 primary (standard) FG colors --

BLACK = 0
RED = 1
GREEN = 2
YELLOW = 3
BLUE = 4
MAGNETA = 5
CYAN = 6
WHITE = 7

PRIMARIES = {
    "BLACK": 0,
    "RED": 1,
    "GREEN": 2,
    "YELLOW": 3,
    "BLUE": 4,
    "MAGNETA": 5,
    "CYAN": 6,
    "WHITE": 7,
}

# -- SGR helpers ---

def SGR(n, reset_first=True):
    '''
    Select Graphic Rendition: take in the numeric attribute(s) and
    wrap them in sequence start and end, forming a full escape sequence

    n - the display attribute(s): string, or list/tuple of strings
    reset_first (default): reset previous styling from prior sequences first

      for an example of why you might not want to do reset first:
        "<esc>[1;3mhello <esc>[23mworld"
        would do "hello" bold and italic, and "world" only bold, by simply
        removing the italic attribute, rather than resetting and setting bold on
        for "world"
    '''

    PREFACE = "0;" if reset_first else ""

    if type(n) == str:
        return f"{SS}{PREFACE}{n}{SE}"
    elif type(n) == list or type(n) == tuple:
        return f"{SS}{PREFACE}{';'.join(n)}{SE}"
    else:
        raise InvalidTypeError("display attribute(s) must be string or list or tuple")

def SEQ_LITERAL(n, content=None, include_reset=True):
    '''
    Returns the escape sequence... escaped, along with optional content
       the returned squence can be sent to STDOUT, and it will diplay the
       escape sequence itself, along with any content within, in the style
       of the escape sequence

    n - the display attribute(s): string, or list/tuple of strings
    content: the content proceding the escape sequence, or None
    include_reset: suffix the sequence and optional content with reset/normal sequence
    '''
    seq = SGR(n)
    if content is None:
        content = ''
    if include_reset:
        content = repr(seq+content+RESET)
    else:
        content = repr(seq+content)
    return f"{seq}{content}{RESET}"

# full sequence with display attrs, content, followed by reset
SEQ = lambda n, content: f"{SGR(n)}{content}{RESET}"

def __optdict_to_nlist(args):
    nlist = [
               BOLD if args['bold'] else None,
               FAINT if args['faint'] else None,
               ITALICS if args['italics'] else None,
               UNDERLINE if args['underline'] else None,
               DUNDERLINE if args['dunderline'] else None,
               SLOW_BLINK if args['slow_blink'] else None,
               FAST_BLINK if args['fast_blink'] else None,
               INVERT if args['invert'] else None,
               HIDE if args['hide'] else None,
               STRIKE if args['strike'] else None,
            ]
    return [n for n in nlist if n is not None]

def __RGB_CONTENT(r, g, b, nlist=[], content=None, literal=False, include_reset=True):
    '''
    Return 24bit color escape sequence

    r,g,b: the values for red, green, blue; each between [0,255]
    content: any content to style with the r,g,b color; or None
    literal: return the escape sequence such that it is literally printable
    include_reset: terminate sequence and content with normal style reversion
    '''
    r = check_num_range(r, lower=0, upper=255)
    g = check_num_range(g, lower=0, upper=255)
    b = check_num_range(b, lower=0, upper=255)
    nlist = nlist + [FG_24BIT_FN(r,g,b)]
    if content is None and not literal:
        content = f"{r},{g},{b} | #{hex(r)[2:]}{hex(g)[2:]}{hex(b)[2:]}"
    return SEQ_LITERAL(nlist, content, include_reset) if literal\
            else SEQ(nlist + [FG_24BIT_FN(r,g,b)], content)

def RGB_CONTENT(
        r, g, b,
        content=None,
        literal=False,
        include_reset=True,
        bold=False,
        faint=False,
        italics=False,
        underline=False,
        dunderline=False,
        slow_blink=False,
        fast_blink=False,
        invert=False,
        hide=False,
        strike=False,
    ):
    nlist = __optdict_to_nlist(locals())
    return __RGB_CONTENT(nlist)


def __RGB_HEX_CONTENT(rgb_hex, nlist=[], content=None, literal=False, include_reset=True):
    '''
    Return 24bit color escape sequence

    rgb_hex: a single hex string containing the hex values for red, green, blue
       may be prefixed with '#' or not
       r,g,b hex values must have 2 characters each, between 00 and FF
       upper or lower case both fine
    content: any content to style with the r,g,b color; or None
    literal: return the escape sequence such that it is literally printable
    include_reset: terminate sequence and content with normal style reversion
    '''

    assert type(rgb_hex) == str, "expected rgb_hex to be a string"
    assert (len(rgb_hex) == 7 and rgb_hex[0] == '#') or len(rgb_hex) == 6, \
        "rgb hex may optionally start with '#'" + \
        "and must contain 3 hex bytes for a length of 6 hex chars"

    if len(rgb_hex) == 7:
        rgb_hex = rgb_hex[1:]

    r = int(rgb_hex[0:2], 16)
    g = int(rgb_hex[2:4], 16)
    b = int(rgb_hex[4:6], 16)

    return __RGB_CONTENT(r, g, b, nlist, content, literal, include_reset)

def RGB_HEX_CONTENT(
        rgb_hex,
        content=None,
        literal=False,
        include_reset=True,
        bold=False,
        faint=False,
        italics=False,
        underline=False,
        dunderline=False,
        slow_blink=False,
        fast_blink=False,
        invert=False,
        hide=False,
        strike=False,
    ):
    nlist = __optdict_to_nlist(locals())
    return __RGB_HEX_CONTENT(nlist)

# -- SGR printers --

def __print_3bit_fg(nlist):
    for col, i in PRIMARIES.items():
        content = f"{col} ({i})"
        content = content.ljust(len(content) + 4)
        seq = SEQ(nlist + [FG_PRIMARY_FN(i)], content)
        print(seq, end="")
    print("")

def print_3bit_fg(
        bold=False,
        faint=False,
        italics=False,
        underline=False,
        dunderline=False,
        slow_blink=False,
        fast_blink=False,
        invert=False,
        hide=False,
        strike=False):
    nlist = __optdict_to_nlist(locals())
    __print_3bit_fg(nlist)

def __print_3bit_bg(nlist):
    for col, i in PRIMARIES.items():
        content = f"{col} ({i})"
        content = content.ljust(len(content) + 4)
        seq = SEQ(nlist + [BG_PRIMARY_FN(i)], content)
        print(seq, end="")
    print("")

def print_3bit_bg(
        bold=False,
        faint=False,
        italics=False,
        underline=False,
        dunderline=False,
        slow_blink=False,
        fast_blink=False,
        invert=False,
        hide=False,
        strike=False):
    nlist = __optdict_to_nlist(locals())
    __print_3bit_bg(nlist)

def __print_8bit_fg(nlist):
    for i in range(0, 16):
        for j in range(0, 16):
            pos = i * 16 + j
            content = str(pos).ljust(4)
            seq = SEQ(nlist + [FG_8BIT_FN(pos)], content)
            print(seq, end="")
        print("")

def print_8bit_fg(
        bold=False,
        faint=False,
        italics=False,
        underline=False,
        dunderline=False,
        slow_blink=False,
        fast_blink=False,
        invert=False,
        hide=False,
        strike=False):
    nlist = __optdict_to_nlist(locals())
    __print_8bit_fg(nlist)

def __print_8bit_bg(nlist):
    for i in range(0, 16):
        for j in range(0, 16):
            pos = i * 16 + j
            content = str(pos).ljust(4)
            seq = SEQ(nlist + [BG_8BIT_FN(pos)], content)
            print(seq, end="")
        print("")

def print_8bit_bg(
        bold=False,
        faint=False,
        italics=False,
        underline=False,
        dunderline=False,
        slow_blink=False,
        fast_blink=False,
        invert=False,
        hide=False,
        strike=False):
    nlist = __optdict_to_nlist(locals())
    __print_8bit_bg(nlist)

def cli_dispatch(args, printopts, content=None):
    if args.print_3bit_fg:
        __print_3bit_fg(__optdict_to_nlist(printopts))
    elif args.print_3bit_bg:
        __print_3bit_bg(__optdict_to_nlist(printopts))
    elif args.print_8bit_fg:
        __print_8bit_fg(__optdict_to_nlist(printopts))
    elif args.print_8bit_bg:
        __print_8bit_bg(__optdict_to_nlist(printopts))
    elif args.print_hex:
        print(__RGB_HEX_CONTENT(
            args.print_hex[0],
            nlist=__optdict_to_nlist(printopts),
            content=content,
            literal=args.literal,
            include_reset=args.normal)
        )
    elif args.print_rgb:
        print(__RGB_CONTENT(
            *args.print_rgb,
            nlist=__optdict_to_nlist(printopts),
            content=content,
            literal=args.literal,
            include_reset=args.normal)
        )
    else:
        print("specify a color print option.")

if __name__ == "__main__":
    import sys
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

