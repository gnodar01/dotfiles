#!python

"""
Author: Nodar Gogoberidze
Date: Feb-25-2024
LICENSE: MIT

This program parses text input contining characters encoded in codepage 437:
    https://en.wikipedia.org/wiki/Code_page_437
It maps these characters to their unicode equivalents and outputs them.
It also reads and passes through ANSI escape sequences in the text input:
    https://en.wikipedia.org/wiki/ANSI_escape_code
While doing so it parses the subset of the escape sequences related to cursor
movement.

In combination the parsing of codepage 437 and ANSI allows this program
to parse and output ANSI art:
    https://en.wikipedia.org/wiki/ANSI_art

Usually ANSI art files end in .ANS or .ASC, and are commonly found in archives
extracted from BBS systems, where ANSI art was most prevalant.

The most popular such archive is 16 colors:
    https://16colo.rs/

Although (re)written from scratch, much of this program was written in reference
to elkrammer/fansi C program (MIT License):
    https://github.com/elkrammer/fansi

This program is not particularly efficient or "complete":
    https://forum.16colo.rs/t/how-to-render-ansi-properly/201
It will likely not support some more esoteric (but still valid) ANSI files.
It's mostly made and distributed for illustrative purposes.
As a consequence the code is kept intentionally simple
(and hopefully understandable).
"""

import sys
import io
import time
from enum import Enum

r"""
ways to represent python unicode

"Δ"                               # python is utf-8 by default

"\N{GREEK CAPITAL LETTER DELTA}"  # Using the character name

"\u0394"                          # Using a 16-bit hex value

"\U00000394"                      # Using a 32-bit hex value

b"...".decode("utf-8")

encoding codepoints into a bytes representation is a bit tricky.
see below function "utf8_encode" for nuances.
although the unicode codepoints are in hex, utf-8 is a multibyte 8-bit char set.
all the characters up to 0x7f ie those with a zero in the top of the first
(and only) byte are the same as their ASCII equivalents.
all other characters are multibyte, consisting of a start byte and up to three
extension bytes.
the number of bytes in total is encoded by the number of leading 1 bits in the
start byte.

0xxxxxxx => 1 byte  (\u0000...\u007f)i.e. seven bit ASCII 
110xxxxx => 2 bytes (\u0080...\u07ff)
1110xxxx => 3 bytes (\u0800...\uffff)
11110xxx => 4 bytes (\u10000...\u10ffff)

taking the greek capital letter delta Δ as an example, its code point is
\u0394, which means the hex \x03 and the hex \x94, which in binary is
00000011 10010100

that's a problem, because unicode decoding, going from left to right, will see
the first byte and assume it's an ASCII character (3 - ETX), and decode just the
first byte as that character. then it will move on to the second byte assuming
its the start of a second codepoint, and throw an exception because it starts
with 10 which is not a valid start sequence.

python standard encodings include code page 437 (cp437):
    https://docs.python.org/3/library/codecs.html#standard-encodings

so we can for instance do str.encode("cp437") and bytes.decode("cp437")
"""

r"""
the index 0-255 represents the extended ASCII, code page 437 value
  https://en.wikipedia.org/wiki/Code_page_437
the value at the index is the unicode code point (in hex):
  https://docs.python.org/3/howto/unicode.html
the actual glyph of the code point is controlled by the font being used
by the terminal's font renderer
it so happens that the unicode codepoints for code page 437 are all exactly
2 bytes, although this is not always the case more generally for unicode
not all of the lower 7 bits are exactly ascii:
  https://bestasciitable.com/
for example in ascii, 0x03 is ETX (end of text), but in code page 437
it is a heart ♥
"""

# PARAMETERS
NO_CONVERT_ASCII = True
# only accept .ans .asc
FILTER_EXT = True
# print the filename before displaying
PRINT_BEFORE = True
# print the filename after displaying
PRINT_AFTER = True
# shuffle the directory contents used for screen saver
SHUFFLE_SSAVER = True
# convert null characters to spaces
NULL_TO_SPACE = True
# replace set bg to black (40m) with default bg color (49m)
BLACK_TO_DEFAULT = True

CP437_CODEPOINTS = [
    # 0 - 127
    "\u0000","\u263A","\u263B","\u2665",
    "\u2666","\u2663","\u2660","\u2022",
    "\u25D8","\u25CB","\u25D9","\u2642",
    "\u2640","\u266A","\u266B","\u263C",
    "\u25BA","\u25C4","\u2195","\u203C",
    "\u00B6","\u00A7","\u25AC","\u21A8",
    "\u2191","\u2193","\u2192","\u2190",
    "\u221F","\u2194","\u25B2","\u25BC",
    "\u0020","\u0021","\u0022","\u0023",
    "\u0024","\u0025","\u0026","\u0027",
    "\u0028","\u0029","\u002A","\u002B",
    "\u002C","\u002D","\u002E","\u002F",
    "\u0030","\u0031","\u0032","\u0033",
    "\u0034","\u0035","\u0036","\u0037",
    "\u0038","\u0039","\u003A","\u003B",
    "\u003C","\u003D","\u003E","\u003F",
    "\u0040","\u0041","\u0042","\u0043",
    "\u0044","\u0045","\u0046","\u0047",
    "\u0048","\u0049","\u004A","\u004B",
    "\u004C","\u004D","\u004E","\u004F",
    "\u0050","\u0051","\u0052","\u0053",
    "\u0054","\u0055","\u0056","\u0057",
    "\u0058","\u0059","\u005A","\u005B",
    "\u005C","\u005D","\u005E","\u005F",
    "\u0060","\u0061","\u0062","\u0063",
    "\u0064","\u0065","\u0066","\u0067",
    "\u0068","\u0069","\u006A","\u006B",
    "\u006C","\u006D","\u006E","\u006F",
    "\u0070","\u0071","\u0072","\u0073",
    "\u0074","\u0075","\u0076","\u0077",
    "\u0078","\u0079","\u007A","\u007B",
    "\u007C","\u007D","\u007E","\u2302",

    # 128-255
    "\u00C7","\u00FC","\u00E9","\u00E2",
    "\u00E4","\u00E0","\u00E5","\u00E7",
    "\u00EA","\u00EB","\u00E8","\u00EF",
    "\u00EE","\u00EC","\u00C4","\u00C5",
    "\u00C9","\u00E6","\u00C6","\u00F4",
    "\u00F6","\u00F2","\u00FB","\u00F9",
    "\u00FF","\u00D6","\u00DC","\u00A2",
    "\u00A3","\u00A5","\u20A7","\u0192",
    "\u00E1","\u00ED","\u00F3","\u00FA",
    "\u00F1","\u00D1","\u00AA","\u00BA",
    "\u00BF","\u2310","\u00AC","\u00BD",
    "\u00BC","\u00A1","\u00AB","\u00BB",
    "\u2591","\u2592","\u2593","\u2502",
    "\u2524","\u2561","\u2562","\u2556",
    "\u2555","\u2563","\u2551","\u2557",
    "\u255D","\u255C","\u255B","\u2510",
    "\u2514","\u2534","\u252C","\u251C",
    "\u2500","\u253C","\u255E","\u255F",
    "\u255A","\u2554","\u2569","\u2566",
    "\u2560","\u2550","\u256C","\u2567",
    "\u2568","\u2564","\u2565","\u2559",
    "\u2558","\u2552","\u2553","\u256B",
    "\u256A","\u2518","\u250C","\u2588",
    "\u2584","\u258C","\u2590","\u2580",
    "\u03B1","\u00DF","\u0393","\u03C0",
    "\u03A3","\u03C3","\u00B5","\u03C4",
    "\u03A6","\u0398","\u03A9","\u03B4",
    "\u221E","\u03C6","\u03B5","\u2229",
    "\u2261","\u00B1","\u2265","\u2264",
    "\u2320","\u2321","\u00F7","\u2248",
    "\u00B0","\u2219","\u00B7","\u221A",
    "\u207F","\u00B2","\u25A0","\u00A0",
]

# baud rate / characters per second
DEFAULT_SPEED = 800
DEFAULT_WIDTH = 80

# list of accepted extensions if FILTER_EXT is True
EXTS = ['.ASC', '.ANS']
def valid_ext(ext):
    if ext is None or len(ext) == 0:
        return False
    ext = ext.upper()
    if (ext[0] != '.'):
        ext = f".{ext}"
    return ext in EXTS

# Command Sequence Introducer - started by \e[ or \033[ or \x1b
# https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_(Control_Sequence_Introducer)_sequences
CSI = [b"A", b"B", b"C", b"D", b"E", b"F", b"G", b"H", b"J", b"K",
       b"S", b"T", b"f", b"m", b"n", b"s", b"u", b"l", b"h"]
ESC = b"\x1B"
# in ASCII this is SUB, but generally ^Z
# https://en.wikipedia.org/wiki/End-of-file#EOF_character
EOF = b"\x1A"
RESET = b"\x1B\x5B\x30\x6D" # ESC[0m - normal mode (reset SGR)
RESET_N = b"\x1B\x5B\x30\x6D\x0A" # ESC[0m\n

r"""
https://www.acid.org/info/sauce/sauce.htm
http://www.retroarchive.org/swag/DATATYPE/0036.PAS.html

struct sauce_record {
	char                ID[5];
	char                Version[2];
	char                Title[35];
	char                Author[20];
	char                Group[20];
	char                Date[8];
	uint32_t            FileSize;
	unsigned char		DataType;
	unsigned char		FileType;
	uint16_t            TInfo1;
	uint16_t            TInfo2;
	uint16_t            TInfo3;
	uint16_t            TInfo4;
	uint16_t            Flags;
	char                Filler[22];
};

we only care about these fields for now
struct sauce_info {
    char    *workname;
    char    *author;
    char    *group;
    char    *date;
};
"""
SAUCE_STR = "SAUC00"


write = sys.stdout.buffer.write

def utf8_encode(codepoint, res_type="bytes"):
    """
    encodes codepoint to utf-8 representation

    this is purely illustrative, when res_types is "bytes", it's the same as
    just doing codepoint.encode("utf-8")

    https://en.wikipedia.org/wiki/UTF-8#Encoding

    code point <-> utf-8 conversion

    +----------+----------+----------+----------+----------+----------+
    | first cp |  last cp | byte 1   | byte 2   | byte 3   | byte 4   |
    +----------+----------+----------+----------+----------+----------+
    |     dcba       dcba                                             |
    +----------+----------+----------+----------+----------+----------+
    |   U+0000 |   U+007F | 0bbbaaaa |          |          |          |
    |   U+0080 |   U+07FF | 110cccbb | 10bbaaaa |          |          |
    |   U+0800 |   U+FFFF | 1110dddd | 10ccccbb | 10bbaaa  |          |
    | U+010000 | U+10FFFF | 11110fee | 10eedddd | 10ccccbb | 10bbaaaa |
    +----------+----------+----------+----------+----------+----------+
    |   fedcba |   fedcba                                             |
    +----------+----------+----------+----------+----------+----------+
    """
    OBL  = 0x0000   # 0       one byte lower
    OBU  = 0x007F   # 127     one byte upper
    TWBL = 0x0080   # 128     two byte lower
    TWBU = 0x07FF   # 2047    two byte upper
    THBL = 0x0800   # 2048    three byte lower
    THBU = 0xFFFF   # 65535   three byte upper
    FBL  = 0x010000 # 65536   four byte lower
    FBU  = 0x10FFFF # 1114111 four byte upper

    # codepoint binary string
    # [2:] to get rid of "0b" prefix
    CPB = bin(ord(codepoint))[2:]
    int_val = int(CPB, 2)

    # 16 bit binary string
    #unicode_binary = f"{x[2:]:0>16}"

    if int_val >= OBL and int_val <= OBU:
        num_bytes = 1
        utf_binary = f"{CPB:0>8}"
    elif int_val >= TWBL and int_val <= TWBU:
        num_bytes = 2
        CPB = f"{CPB:0>16}"
        utf_binary = f"110{CPB[5:10]}10{CPB[10:16]}"
    elif int_val >= THBL and int_val <= THBU:
        num_bytes = 3
        CPB = f"{CPB:0>16}"
        utf_binary = f"1110{CPB[0:4]}10{CPB[4:10]}10{CPB[10:16]}"
    elif int_val >= FBL and int_val <= FBU:
        num_bytes = 4
        CPB = f"{CPB:0>24}"
        utf_binary = f"11110{CPB[4:7]}10{CPB[7:13]}10{CPB[13:19]}10{CPB[19:25]}"
    else:
        raise Exception(f"Not a valid codepoint {codepoint}, (int) {int_val}, (hex) {hex(int_val)}")

    if res_type == "binary":
        return utf_binary
    elif res_type == "int":
        return int(utf_binary, 2)
    elif res_type == "hex":
        return hex(int(utf_binary, 2))
    elif res_type == "bytes":
        # big endian
        return int(utf_binary, 2).to_bytes(num_bytes, "big")

def print_codepoint_names():
    """
    display information on all cp437 characters, including character names
    character codes are abbreviations describing the nature of the character
    grouped by categories like "Letter", "Number, "Punctuation", or "Symbol",
    which in turn are grouped into subcategories

    https://www.unicode.org/reports/tr44/#General_Category_Values
    """
    import unicodedata

    for i, c in enumerate(CP437_CODEPOINTS):
        enc_b = utf8_encode(c)
        # decimal index, hex index, codepoint, byte encoding, category, glyph, char name
        print(f"{i:<3}",
              f"{hex(i):<4}",
              "U+%04x" % ord(c),
              "\\x"+"\\x".join(map(lambda b: f"{str(hex(b))[2:]:0>2}", list(enc_b))),
              "    "*(3-len(enc_b)),
              unicodedata.category(c),
              c,
              end=" ")
        try:
            print(unicodedata.name(c))
        except:
            print("no name")

def exit_err(msg):
    parser.print_usage(file=sys.stderr)
    print(f"fansi: error: {msg}", file=sys.stderr)
    parser.exit(2)

def print_cp437():
    y = 0;
    for x in range(256):
        print(CP437_CODEPOINTS[x], end="")
        y += 1
        if (y == 32):
            print("\u000A", end="")
            y = 0;

def stream_ansi(fs, speed=DEFAULT_SPEED, width=DEFAULT_WIDTH):
    """
    fs: filestream is a raw I/O stream
        e.g. open(fname, "rb") or open(fname, "rb", encoding="utf-8").buffer
             or sys.stdin.buffer, etc
    """
    # could just do .encode("utf8") instead of utf8_encode
    b_to_ch = lambda abyte: \
            utf8_encode(
                CP437_CODEPOINTS[
                    # or could just do abyte[0] since we know its 1 byte
                    int(artwork_c.hex(), 16)])

    # FSM
    State = Enum("State",
                 ["CONTINUE", "GET_NEXT_CHAR", "CHECK_IF_CSI", "PARSE_CSI_SEQ"])

    state = State.CONTINUE
    EOF_reached = False # continue parsing
    # not the same as fs.tell() (byte position in file)
    # cursor_pos is with respect to column position within a row
    cursor_pos = 0 # set intiial cursor position
    saved_cursor = 0 # saved cursor position
    # "did_newline" serves as a flag which is enabled when we write out a
    # newline character because "cursor_pos" is at max width
    #
    # the flag is needed because the next character to write out from the input
    # stream might itself be a newline character (in which case we'd double
    # newline)
    # however, it might not be the *immediate* next character because
    # some ANSI escape sequence(s) might also precede it
    #
    # we also can't rely on cursor_pos == 0 alone because the input stream may
    # purposely have several newlines at pos 0 for artistic effect
    #
    # "did_newline" should be disabled after cursor moves past position 0
    did_newline = False
    # "first_r" and "first_n" are flags for the situation when the input stream
    # purposefully has multiple newlines in a row
    # when we write a newline because width is reached we want to ignore the
    # immediate next printable character if it is also "\r" or "\n",
    # but any subsequent ones should be let through
    #
    # these should be disabled alongside disabling of "did_newline"
    first_r = False
    first_n = False

    cmd = None # store the last seen CSI command
    cmd_arg_buffer = [] # buffer to store the CSI command argument
    cmd_args = [] # the list of full arguments

    while(not EOF_reached):
        # don't read while wei're in cmd argument parsing
        # we have to parse the cmd arguments and output them
        # only then do we output the cmd itself
        # fnally we can continue reading
        if (state != State.PARSE_CSI_SEQ):
            artwork_c = fs.read(1)

        if artwork_c == b"":
            break

        if cursor_pos != 0 and did_newline:
            did_newline = False
            first_r = False
            first_n = False

        if (state == State.CONTINUE):
            # check if this is an escape sequence
            if (artwork_c == ESC): # starts all escape sequences
                write(artwork_c)
                state = State.GET_NEXT_CHAR
            elif (artwork_c == EOF):
                EOF_reached = True
                break;
            # print characters to screen and advance cursor pos
            else:
                if speed > 0:
                    # slow down output to defined speed
                    time.sleep(1/speed)

                if (artwork_c == b"\r" and did_newline and not first_r):
                    first_r = True
                    continue
                if (artwork_c == b"\n" and did_newline and not first_n):
                    first_n = True
                    continue

                # character needs to be converted to unicode
                # if > 127, not strict ascii
                # can just do artwork_c.isascii()
                if (NO_CONVERT_ASCII and artwork_c > b"\x7f"):
                    write(b_to_ch(artwork_c))
                # if encountering the NUL character let it flow through as
                # a space instead; here's an example file with NULs:
                # https://github.com/blocktronics/artpacks/blob/master/Detention%20Block%20AA-23/ANSI_Star_Wars_misfit%20-%20ig-88.ans
                elif (NULL_TO_SPACE and artwork_c == b"\x00"):
                    write(b" ")
                else:
                    write(artwork_c)

                # typically ANSI art has a limit of 80 characters per row
                # but particularly recently, 160 and other widths are common
                # in any case we paramatize the width
                if (cursor_pos < width-1):
                    cursor_pos += 1
                else:
                    if (artwork_c == b"\n"):
                        write(RESET)
                    else:
                        write(RESET_N)
                        did_newline = True
                    cursor_pos = 0

                # reset cursor_pos if this is a newline
                if (artwork_c == b"\n" or artwork_c == b"\r"):
                    cursor_pos = 0
        elif (state == State.GET_NEXT_CHAR):
            write(artwork_c)
            if (artwork_c == b"["):
                state = State.CHECK_IF_CSI
        elif (state == State.CHECK_IF_CSI):
            if (artwork_c in CSI or artwork_c == b";"):
                state = State.PARSE_CSI_SEQ
                cmd = artwork_c
            # there are some private sequences of the form CSI ? <some_num> <cmd>
            # adding "?" to buffer will break the int conversion later on of "cmd_arg_buffer"
            # later on, and we don't rely on "?" internally anyway, so just let it flow through
            # nothing about the cursor position needs to change
            # this .ANS file shows an example ("\x1b[?33h" at the beginning):
            # https://github.com/blocktronics/artpacks/blob/master/ACiD%20Trip/ziiig-LOL.ANS
            elif (artwork_c == b"?"):
                write(artwork_c)
            else:
                # chars used in esqcape sequences are all ascii
                # store them as such
                cmd_arg_buffer.append(artwork_c.decode("ascii"))
        elif (state == State.PARSE_CSI_SEQ):
            # concat the argument parts and convert to int
            # add to the list of arguments for this CSI command
            if (len(cmd_arg_buffer) > 0):
                cmd_args.append( int(''.join(cmd_arg_buffer)) )
            # reset the buffer for the next arg
            cmd_arg_buffer = []

            # CSI n (E | F)
            # Cursor Next Line (CNL) or Cursor Previous Line (CPL)
            # move cursor to next (E) or previous (F) line
            if (cmd == b'E' or cmd == b'F'):
                cursor_pos = 0
                write(RESET_N)

            # CSI n G
            # Cursor Horizontal Absolute (CHA)
            # move cursor to specified column
            if (cmd == b'G'):
                cursor_pos = cmd_args[0]-1

            # CSI n ; m (H | f)
            # Cursor Position (CUP) or Horizontal Vertical Position (HVP)
            # set cursor position
            # we don't care about vertical pos internally so we just ouput that
            # and move cursor_pos according to m
            if (cmd == b'H' or cmd == 'f'):
                cursor_pos = cmd_args[1] - 1

            # CSI n C
            # Cursor Forward (CUF)
            # move cursor forward
            if (cmd == b'C'):
                cursor_pos = cursor_pos + cmd_args[0]
                if (cursor_pos >= width):
                    write(RESET_N)
                    cursor_pos = cursor_pos % width

            # CSI n D
            # Cursor Backward (CUB)
            # move cursor back
            if (cmd == b'D'):
                if (cursor_pos != 0):
                    cursor_pos = cursor_pos - args[0]

            # CSI s
            # Save Current Curosr Position (SCP / SCOSC)
            if (cmd == b's'):
                saved_cursor = cursor_pos

            # CSI u
            # Restore Saved Cursor Position (RCP / SCORC)
            if (cmd == b'u'):
                cursor_pos = saved_cursor

            # CSI char or ; puts us in parsing state but only
            # CSI char ends checking/parsing
            if cmd in CSI:

                # this is for SGR mode
                # instead of setting background black
                # set it to default
                # only with "m" else would interfere with other CSI commands
                # like cursor movements, etc
                if (BLACK_TO_DEFAULT and cmd == b'm' and 40 in cmd_args):
                    cmd_args = [ca if ca != 40 else 49 for ca in cmd_args]

                cmd_seq = ';'.join(map(lambda num: str(num), cmd_args))

                for ca in cmd_seq:
                    write(ca.encode('utf8'))

                write(cmd)

                cmd = None
                cmd_args = []
                state = State.CONTINUE
            else:
                state = State.CHECK_IF_CSI
        # end state switch
        sys.stdout.buffer.flush()
    # end while loop
    write(RESET_N)
    sys.stdout.buffer.flush()

if __name__ == "__main__":
    import os
    import select
    import argparse

    logo = \
        "\033[38;5;162m" \
        " ·▄▄▄▄ ▄. ▄▄  ·▄▄▄ ▄▄▄·  ▐ ▄ .▄▄ · ▪  \n" \
        " ▐▄▄▄█  █▄▐▪  ▐▄▄·▐█ ▀█ •█▌▐█▐█ ▀. ██ \n" \
        "  █  ·  . █·  ██▪ ▄█▀▀█ ▐█▐▐▌▄▀▀▀█▄▐█·\n" \
        "  █▌.  • ██   ██▌.▐█ ▪▐▌██▐█▌▐█▄▪▐█▐█▌\n" \
        " ▀▀▀  .  ▀▀▀  ▀▀▀  ▀  ▀ ▀▀ █▪ ▀▀▀▀ ▀▀▀"   \
        "\033[0m"

    parser = argparse.ArgumentParser(
            prog="fansi",
            description=logo,
            formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument("--speed", nargs=1, metavar="value", type=int, default=DEFAULT_SPEED,
                        help=f"Set rendering speed. Default is {DEFAULT_SPEED}.\nDecrease it to slow down the output.\nSet to 0 for no slowdown.")
    parser.add_argument("-s", "--ssaver", nargs=1, metavar="dirname", help="Screen Saver mode.")
    parser.add_argument("--sauce", nargs=1, metavar="filename", help="Print SAUCE metadata for file.")
    parser.add_argument("--width", nargs=1, metavar="int >= 80", type=int, default=DEFAULT_WIDTH,
                        help=f"Terminal width expected, default is {DEFAULT_WIDTH}.")
    parser.add_argument("--cp437", action="store_true", help="Print Code Page 437 table as UTF-8 characters.")
    parser.add_argument("--cp437-long", action="store_true", help="Print info on each character in Code Page 437.")
    parser.add_argument("filename", nargs="?")

    args = parser.parse_args()

    # nargs provide lists, even when nargs=1
    if args.ssaver is not None:
        args.ssaver = args.ssaver[0]
    if args.sauce is not None:
        args.sauce = args.sauce[0]
    if type(args.speed) == list:
        args.speed = args.speed[0]
    if type(args.width) == list:
        args.width = args.width[0]

    # determine if stdin is available for reading
    # this is just the select syscall; man select
    # this method is preferable to sys.stdin.isatty becaus it works even in the
    # case of remote invocation (eg ssh)
    rlist,_,_ = select.select([sys.stdin],[],[],0)

    # count the number of sources of content from args
    num_sources = 0
    if len(rlist) != 0:
        num_sources += 1
    if args.ssaver is not None:
        num_sources += 1
    if args.filename is not None:
        num_sources += 1
    if args.sauce is not None:
        num_sources += 1

    print_info = args.cp437 or args.cp437_long

    if num_sources != 1 and not print_info:
        exit_err("provide exactly one of: a dirname with --ssaver, a fileanme with --sauce, or just a filename, or provide stdin")
    if num_sources >= 1 and print_info:
        exit_err("--cp437[-long] should not have file/dir/stdin")
    if args.filename is not None and not os.path.isfile(args.filename):
        exit_err(f"{args.filename} is not a file")
    if args.sauce is not None and not os.path.isfile(args.sauce):
        exit_err(f"{args.sauce} is not a file")
    if args.ssaver is not None and not os.path.isdir(args.ssaver):
        exit_err(f"{args.ssaver} is not a directory")
    if args.speed < 0:
        exit_err(f"speed must be non-negative, got {args.speed}")
    if args.width < 1:
        exit_err(f"width must be positive, got {args.width}")

    if FILTER_EXT and args.filename is not None:
        ext = os.path.splitext(args.filename)[-1]
        if not valid_ext(ext):
            exit_err(f"filename must have {', '.join(EXTS).lower()} as extension, got {args.filename} ({ext})")

    ssaver_files = []
    if args.ssaver is not None:
        from pathlib import Path

        file_gen = Path(args.ssaver).rglob('*.*')

        if SHUFFLE_SSAVER:
            import random
            file_gen = list(file_gen)
            random.shuffle(file_gen)

        for f in file_gen:
            ext = os.path.splitext(f)[-1]
            if FILTER_EXT and valid_ext(ext):
                ssaver_files.append(f)
            elif not FILTER_EXT:
                ssaver_files.append(f)

        if (len(ssaver_files) == 0):
            exit_err(f"No ANSI Art files found in directory {args.ssaver}")

    if print_info:
        if args.cp437_long:
            print_codepoint_names()
        if args.cp437:
            print_cp437()
    elif args.sauce:
        #print_sauce(args.filename)
        ...
    elif args.ssaver is not None:
        for f in ssaver_files:
            PRINT_BEFORE and print(f"vvv {f} vvv")
            f_stream = open(f, "rb")
            try:
                stream_ansi(f_stream, speed=args.speed, width=args.width)
            except KeyboardInterrupt:
                f_stream.close()
                write(RESET_N)
                print(f)
                exit(1)
            PRINT_AFTER and print(f"^^^ {f} ^^^")
            f_stream.close()
    elif args.filename is not None:
        PRINT_BEFORE and print(f"vvv {args.filename} vvv")
        f_stream = open(args.filename, "rb")
        try:
            stream_ansi(f_stream, speed=args.speed, width=args.width)
        except KeyboardInterrupt:
            f_stream.close()
            write(RESET_N)
            print(args.filename)
            exit(1)
        f_stream.close()
        PRINT_AFTER and print(f"^^^ {args.filename} ^^^")
        exit(0)
    elif rlist:
        # don't want utf-8, want raw bytes
        f_stream = rlist[0].buffer if type(rlist[0]) == io.TextIOWrapper else rlist[0]
        try:
            stream_ansi(f_stream, speed=args.speed, width=args.width)
        except KeyboardInterrupt:
            write(RESET_N)
            exit(1)
        exit(0)

    exit(1)

