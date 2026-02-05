#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Made by
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Created on: Wed 26 Feb 2025 10:36:45 AM GMT
# config.py
# Description:
#  The configuration file of qutebrowser

import os
import urllib.parse
import dracula.draw

config.load_autoconfig(True)
config.bind('pnt', ':spawn -vom %s/go/bin/nuclei -silent -no-color -H \'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0\' -t http/technologies/ -u {url}' % os.getenv('HOME'))
config.bind('pnc', ':spawn -vom %s/go/bin/nuclei -silent -no-color -H \'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0\' -t http/cves/ -u {url}' % os.getenv('HOME'))
config.bind('pws', ':spawn -wom wpscan --url {url} -e u --rua')
config.bind('pwc', ':open -t https://web-check.xyz/check/https%3A%2F%2F{url:host}')
config.bind('M', 'hint links spawn mpv {hint-url}')
c.auto_save.session = True
c.content.blocking.method = "both"
c.colors.webpage.darkmode.enabled = False
c.content.cookies.accept = "no-3rdparty"
c.tabs.title.format = "{audio}{index}: {current_url}"

dracula.draw.blood(c, {
    'spacing': {
        'vertical': 6,
        'horizontal': 8
    }
})
