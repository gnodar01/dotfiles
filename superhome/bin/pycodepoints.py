#!python3

import sys
import unicodedata


WHITESPACE = b"\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F\x20"

# codepoint formats (case insensitive): 0x00ae | u+00a2 | \u00a2 | 00a2
# decimal fromat: decimal equivilent of codepoint, e.g. 162
# unicode: the literal unicode character, e.g. ¢
# bytes: the byte encoding of the unicode, e.g. \xc2\xa2

# https://www.unicode.org/reports/tr44/
def u_to_n(bchr):
    # https://www.unicode.org/Public/15.0.0/ucd/NameAliases.txt
    if ord(bchr) == 0x00:
        return "NULL"
    elif ord(bchr) == 0x01:
        return "START OF HEADING"
    elif ord(bchr) == 0x02:
        return "START OF TEXT"
    elif ord(bchr) == 0x03:
        return "END OF TEXT"
    elif ord(bchr) == 0x04:
        return "END OF TRANSMISSION"
    elif ord(bchr) == 0x05:
        return "ENQUIRY"
    elif ord(bchr) == 0x06:
        return "ACKNOWLEDGE"
    elif ord(bchr) == 0x07:
        return "BEL"
    elif ord(bchr) == 0x08:
        return "BACKSPACE"
    elif ord(bchr) == 0x09:
        return "TAB"
    elif ord(bchr) == 0x0a:
        return "NEW LINE"
    elif ord(bchr) == 0x0b:
        return "VERTICAL TABULATION"
    elif ord(bchr) == 0x0c:
        return "FORM FEED"
    elif ord(bchr) == 0x0d:
        return "CARRIAGE RETURN"
    elif ord(bchr) == 0x0e:
        return "SHIFT OUT"
    elif ord(bchr) == 0x0f:
        return "SHIFT IN"
    elif ord(bchr) == 0x10:
        return "DATA LINK ESCAPE"
    elif ord(bchr) == 0x11:
        return "DEVICE CONTROL ONE"
    elif ord(bchr) == 0x12:
        return "DEVICE CONTROL TWO"
    elif ord(bchr) == 0x13:
        return "DEVICE CONTROL THREE"
    elif ord(bchr) == 0x14:
        return "DEVICE CONTROL FOUR"
    elif ord(bchr) == 0x15:
        return "NEGATIVE ACKNOWLEDGE"
    elif ord(bchr) == 0x16:
        return "SYNCHRONOUS IDLE"
    elif ord(bchr) == 0x17:
        return "END OF TRANSMISSION BLOCK"
    elif ord(bchr) == 0x18:
        return "CANCEL"
    elif ord(bchr) == 0x19:
        return "END OF MEDIUM"
    elif ord(bchr) == 0x1a:
        return "SUBSTITUTE"
    elif ord(bchr) == 0x1b:
        return "ESCAPE"
    elif ord(bchr) == 0x1c:
        return "FILE SEPARATOR"
    elif ord(bchr) == 0x1d:
        return "GROUP SEPARATOR"
    elif ord(bchr) == 0x1e:
        return "RECORD SEPARATOR"
    elif ord(bchr) == 0x1f:
        return "UNIT SEPARATOR"
    elif ord(bchr) == 0x20:
        return "SP"
    elif ord(bchr) == 0x7f:
        return "DELETE"
    else:
        return unicodedata.name(bchr)

def bytes_to_unicode(bcontents):
    return bcontents.decode("utf8")

def bytes_to_dec(bcontents):
    u = bytes_to_unicode(bcontents)
    return " ".join(map(lambda c: str(ord(c)), u))

def bytes_to_codepoints(bcontents, prefix="U+", long_fmt=False):
    u = bytes_to_unicode(bcontents)
    if long_fmt:
        return " ".join(map(lambda c: f"{prefix}{hex(ord(c))[2:]:>08}", u))
    else:
        return " ".join(map(lambda c: f"{prefix}{hex(ord(c))[2:]:>04}", u))

def bytes_to_names(bcontents):
    u = bytes_to_unicode(bcontents)
    return "\n".join(map(lambda c: u_to_n(c), u))

def bytes_to_bytesr(bcontents):
    """
    bytes is actualy bytes
    bytesr is printable representation of bytes
    """
    u = bytes_to_unicode(bcontents)
    res = ""
    for c in u:
        int_val = ord(c)
        if int_val <= 0x7f:
            res += f"\\x{hex(int_val)[2:]:>02}"
        else:
            # bytes in big endian, but str fmt
            be = hex(int.from_bytes(c.encode("utf8"), "big"))[2:]
            start = 0
            end = 2
            while end <= len(be):
                res += f"\\x{be[start:end]}"
                start += 2
                end += 2
    return res

def names_to_bytes(names_b):
    return "".join(map(
        lambda n: unicodedata.lookup(n), filter(
            lambda b: b != b"", names_b.split(b'\n')
        )
    )).encode("utf8")

def codepoints_to_bytes(codepoints_b, long_fmt=False):
    contents = codepoints_b.translate(None, WHITESPACE).lower()

    if contents.startswith(b"u+"):
        contents = contents.split(b"u+")[1:]
    elif contents.startswith(b"\u"):
        contents = contents.split(b"\u")[1:]
    elif contents.startswith(b"0x"):
        contents = contents.split(b"0x")[1:]
    else:
        new_contents = []
        n = 8 if long_fmt else 4
        start = 0
        end = n
        while end <= len(contents):
            new_contents.append(contents[start:end])
            start += n
            end += n
        contents = new_contents

    return reduce(
        lambda x,y: x+y,
        map(lambda c: chr(int(c, 16)).encode("utf8"), contents)
    )

def dec_to_bytes(dec_b):
    return "".join(map(
        lambda c: chr(int(c)), dec_b.translate(
            bytes.maketrans(WHITESPACE, b" "*len(WHITESPACE))
        ).strip(b" ").split(b" ")
    )).encode("utf8")

def bytesr_to_bytes(bytesr_b):
    return reduce(
        lambda x,y: x+y,
        map(
            lambda c: int(c, 16).to_bytes(1,"big"),
            bytesr_b.translate(None, WHITESPACE).lower().split(b"\\x")[1:]
        ),
        b''
    )

def exit_err(msg):
    parser.print_usage(file=sys.stderr)
    print(f"fansi: error: {msg}", file=sys.stderr)
    parser.exit(2)

if __name__ == "__main__":
    import select
    import argparse
    from functools import reduce

    choices = [
        ("c", "codepoint"),
        ("d", "decimal"),
        ("u", "unicode"),
        ("b", "bytes"),
        ("n", "name"),
    ]
    formats = {
        choices[0][0]: choices[0],
        choices[0][1]: choices[0],
        choices[1][0]: choices[1],
        choices[1][1]: choices[1],
        choices[2][0]: choices[2],
        choices[2][1]: choices[2],
        choices[3][0]: choices[3],
        choices[3][1]: choices[3],
        choices[4][0]: choices[4],
        choices[4][1]: choices[4],
    }

    parser = argparse.ArgumentParser(
             prog="pycodepoints",
             description=r"""
Converts from a unicode representation to another one
                
    bytes are always delimited by \x, whitespace is ignored

    codepoints can be delimited by 0x, 0X, u+, U+, \u, \U
        or every length n hex is taken, where n is 4 by default or 8 if -U flag provided;
        whitespace is always ignored

    decimal, and unicode are delimited by any whitespace

    names must be delimted by newline
             """,
             formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument("-f", default="unicode", choices=formats.keys(), help="from format")
    parser.add_argument("-t", default="codepoint", choices=formats.keys(), help="to format")
    parser.add_argument("-U", action="store_true")
    parser.add_argument("filename", nargs="?")

    args = parser.parse_args()

    if sys.stdin.isatty():
        piping = False
    else:
        piping = True

    if args.filename is not None:
        f_stream = open(args.filename, "rb")
    elif piping:
        f_stream = sys.stdin.buffer
    else:
        parser.print_usage(file=sys.stderr)
        print("provide one of stdin or filename", file=sys.stderr)
        exit(1)

    bcontents = b""
    if args.f in formats["b"]:
        bcontents = bytesr_to_bytes(f_stream.read())
    elif args.f in formats["d"]:
        bcontents = dec_to_bytes(f_stream.read())
    elif args.f in formats["u"]:
        bcontents = f_stream.read()
    elif args.f in formats["c"]:
        bcontents = codepoints_to_bytes(f_stream.read(), args.U)
    elif args.f in formats["n"]:
        bcontents = names_to_bytes(f_stream.read())

    if args.t in formats["b"]:
        print(bytes_to_bytesr(bcontents))
    elif args.t in formats["d"]:
        print(bytes_to_dec(bcontents))
    elif args.t in formats["u"]:
        print(bytes_to_unicode(bcontents))
    elif args.t in formats["c"]:
        print(bytes_to_codepoints(bcontents, prefix="U+", long_fmt=args.U))
    elif args.t in formats["n"]:
        print(bytes_to_names(bcontents))

    if args.filename is not None:
        f_stream.close()

    exit(0)

