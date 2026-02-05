#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Made by papi
# Created on: Fri 26 Jan 2024 10:59:55 PM CET
# ssh_glue.py
# Description:
#  Run ssh -N -L commands for accessing services inside of p3ng0s cloud services
#  will save the pid inside of a temp file in /tmp/glue.cfg since at reboot the
#  commands will be stopped.
# Usage:
#  ./ssh_glue.py -s [service_name]
#  ./ssh_plug.py -c [ssh_string]
# Supported services
#  - bloodhound  --> This is mapped to port 8080 on the server side and on the client side
#  - wazuh       --> This is mapped to port 443 on the server side and 8081 on the client

import os, sys, json
import getopt

PID_FILE_COMMAND = "%s:%s:%s.glue"
CONFIG_FILE = os.environ['HOME'] + "/.p3ng0s.json"
CONFIG_DATA = {}

# Thx stack overflow <3
# https://stackoverflow.com/questions/287871/how-do-i-print-colored-text-to-the-terminal
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def usage():
    print(bcolors.HEADER + "./ssh_glue.py:" + bcolors.ENDC)
    print("\t -s [service_name]" + bcolors.ENDC)
    print("\t -c [ssh_string]" + bcolors.ENDC)
    print("---------" + bcolors.ENDC)
    print(bcolors.HEADER + "Services:" + bcolors.ENDC)
    print("\tAll of the ports and should be configure inside of ~/.p3ng0s.json" + bcolors.ENDC)
    print("\tbloodhound -> .bloodhound -> server .bloodhound_port -> port on server and client .user -> ssh user used" + bcolors.ENDC)
    print("\twazuh -> .soc -> the server .soc_rport -> remote soc port .soc_lport -> soc local port .soc_user -> the soc user for ssh" + bcolors.ENDC)
    print(bcolors.HEADER + "Example:" + bcolors.ENDC)
    print("\t ./ssh_glue.py -s bloodhound" + bcolors.ENDC)
    print("\t ./ssh_glue.py -c user@server:8080:localhost:8080" + bcolors.ENDC)
    sys.exit(-1)

def connect_to_server(user, server, port_server, port_client):
    process_id = os.fork()
    command = "/usr/bin/ssh"
    args = [command, "%s@%s" % (user, server), "-N", "-L",
            "%s:localhost:%s" % (port_client, port_server)]
    if process_id == 0:
        os.execve(command, args, os.environ)
        sys.exit(0)
    return process_id

def handle_connection(user, server, port_server, port_client):
    FILE = "/tmp/" + PID_FILE_COMMAND % (port_client, server, port_server)


    if os.path.exists(FILE):
        with open(FILE, "r") as fp:
            os.system("kill %d" % (int(fp.read().strip())))
        os.system("rm -rf %s" % FILE)
    else:
        with open(FILE, "w") as fp:
            fp.write(str(connect_to_server(user, server, port_server, port_client)))

def handle_service(service):
    global CONFIG_DATA
    user=None
    server=None
    port_server=None
    port_client=None
    if service == "bloodhound":
        server = CONFIG_DATA["bloodhound"]["server"]
        user = CONFIG_DATA["bloodhound"]["user"]
        port_client = CONFIG_DATA["bloodhound"]["lport"]
        port_server= CONFIG_DATA["bloodhound"]["rport"]
    elif service == "wazuh":
        server = CONFIG_DATA["soc"]["server"]
        user = CONFIG_DATA["soc"]["user"]
        port_client = CONFIG_DATA["soc"]["lport"]
        port_server= CONFIG_DATA["soc"]["rport"]
    else:
        usage()
    handle_connection(user, server, port_server, port_client)

if __name__ == "__main__":
    with open(CONFIG_FILE, "r") as fp:
        CONFIG_DATA = json.load(fp)
    opts, args = getopt.getopt(sys.argv[1:], "s:c:h", ["service=", "cmd=", "help"])
    port = 0

    for opt, arg in opts:
        if opt in ("-s", "--service"):
            handle_service(arg)
        elif opt in ("-c", "--cmd"):
            ssh_args_port = arg.split(':')
            ssh_args_user = ssh_args_port[0].split('@')
            handle_connection(ssh_args_user[0], ssh_args_user[1],
                          ssh_args_port[1], ssh_args_port[3])
        else:
            usage()
