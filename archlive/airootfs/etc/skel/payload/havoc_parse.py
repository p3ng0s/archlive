#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Made by papi
# Created on: Sat 30 Mar 2024 01:18:15 PM CET
# havoc_parse.py
# Description:
#  A python script to take a binary and covert it to different formats
# Formats:
#  - cs -> C# buffer array
#  - vba -> vba for office suite
#  - ps -> powershell
# Usage:
#  - python havoc_parse.py -x 136 -c 5 -f ./file.bin -l cs -o /opt/windows/cs_bytecode.txt 2> /opt/windows/decrypt_code.cs
#  -> this command will produce a vba byte array with a cesar cypher of 5 and a xor of 136.
#  -> the decryption code will then need to be: buf(i) = buf(i) - 2
# TODO:
#  - Add support for C format & raw

import getopt, sys
import os

#==============================================================================
# This section is going to be gross but it will be for all the code snipets of
# the decoders
#==============================================================================
cs_snippet_decode_cesar='''byte[] buf = new byte[enc.Length];
for (int i = 0; i < enc.Length; i++) {
    buf[i] = (byte)(((uint)enc[i] - %d) & 0xFF);
}'''
cs_snippet_decode_xor='''for (int i = 0; i < enc.Length; i++) {
    enc[i] = enc[i] ^ %d;
}'''
vba_snipper_decode_cesar='''Dim counter As Long
Dim data As Long
For counter = LBound(buf) To UBound(buf)
    data = buf(counter) - %d
    Rem put here the code to move in memory or save to new array ^^
Next counter'''
ps_snipper_decode_cesar='''for($index = 0; $index -lt $buf.count; $index++) {
    $buf[$index] = $buf[$index] - %d
}'''
#==============================================================================

def display_byte(byte, pos, language):
    '''
    [int] -> byte
    [int] -> pos
    Return -> [char]
    '''
    char = ''
    if language == 'vba':
        pos += 1
        char = "%d, " % (byte)
        if pos % 20 == 0:
            char += "_\n"
    elif language == 'cs' or language == 'ps':
        char = "0x%x, " % (byte)
        if pos % 20 == 0 and language != 'ps':
            char += "\n\t"
    return char

def run_encoding(byte, cesar, xor):
    val = (int.from_bytes(byte, byteorder='big') + cesar)
    if xor != -1:
        val = val ^ xor
    return val

def encoder(language, file, cesar, xor):
    counter = 0
    encrypted_value = ""
    with open(file, "rb") as fp:
        byte = fp.read(1)
        while byte:
            counter += 1
            encrypted_value += display_byte(run_encoding(byte, cesar, xor), counter, language)
            byte = fp.read(1)
    if language == 'cs':
        return "int[] enc = new int[] {\n\t%s\n};" % encrypted_value[:-2]
    elif language == 'ps':
        return "[Byte[]] $buf = %s" % encrypted_value[:-2]
    elif language == 'vba':
        return "buf = Array(%s)" % encrypted_value[:-2]

def handle_encoded(encoded_data, out_file):
    if out_file == '-':
        print(encoded_data, file=sys.stderr)
    else:
        with open(out_file, "w") as fp:
            fp.write(encoded_data)

def show_decoder(cesar, language, xor):
    if language == 'cs' and cesar > 0:
        if xor != -1:
            print(cs_snippet_decode_xor % xor, file=sys.stderr)
        print(cs_snippet_decode_cesar % cesar, file=sys.stderr)
    if language == 'vba' and cesar > 0:
        print(vba_snipper_decode_cesar % cesar, file=sys.stderr)
    if language == 'ps' and cesar > 0:
        print(ps_snipper_decode_cesar % cesar, file=sys.stderr)

def usage():
    print(f"{sys.argv[0]}: A tool to take a .bin file and display it in")
    print("different formats with reversible encryption techniques.")
    print("Usage:")
    print("\t-h --help\tThis current output.")
    print("\t-l --lang=\tLanguage format for the output (cs, ps, vba).")
    print("\t-f --file=\tThe file to read from.")
    print("\t-o --output=\tThe output file to write the byte code too. Can be (-) for stdout.")
    print("\t-c --cesar=\tThe increment for the cesar cypher (Default: 0).")
    print("\t-x --xor=\tThe increment for the xor cypher.")
    print("Example:")
    print(f"\t$ python {sys.argv[0]} -o - -l cs -f ~/payload/demon.x64.bin -c 2")
    print("\t\x1b[1;31m[!] Saving the encoded data to the specified file\x1b[0m")
    print("\tbyte[] buf = new byte[] {")
    print("\t    0xfe, 0x4a, 0x54, ...")
    print("\t}")
    print("\t\x1b[1;31m[!] The payload decoder sample:\x1b[0m")
    print("\tfor (int i = 0; i < buf.Length; i++) {")
    print("\t    buf[i] = (byte)(((uint)buf[i] - 2) & 0xFF")
    print("\t}")

if __name__ == "__main__":
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hl:f:c:o:x:", ["help", "lang=", "file=", "cesar=", "output=", "xor="])
    except getopt.GetoptError as err:
        print(err)
        usage()
        sys.exit(-1)
    language = None
    file = None
    out_file = ""
    cesar = 0
    xor = -1
    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-l", "--lang"):
            language = a
        elif o in ("-f", "--file"):
            file = a
        elif o in ("-c", "--cesar"):
            cesar = int(a)
        elif o in ("-x", "--xor"):
            xor = int(a)
        elif o in ("-o", "--output"):
            out_file = a
        else:
            usage()
            sys.exit(-1)
    if language in ("vba", "cs", "ps") and os.path.exists(file):
        encoded_data = encoder(language, file, cesar, xor)
        print("\x1b[1;31m[!] Saving the encoded data to the specified file\x1b[0m")
        handle_encoded(encoded_data, out_file)
        print("\x1b[1;31m[!] The payload decoder sample:\x1b[0m")
        show_decoder(cesar, language, xor)
    else:
          print("not the correct output format or file")
          sys.exit(-1)
