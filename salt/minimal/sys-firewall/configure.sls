# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% set common_pkgs = [
    'qubes-core-agent-networking',
    'qubes-core-agent-dom0-updates',
    'net-tools',
    'nmap',
    'tcpdump',
    'telnet',
    'wireshark',
] %}

{% set release_pkgs = salt['grains.filter_by']({
    'RedHat': [
        'nmap-ncat',
        'bind-utils',
    ],
   'Debian': [
       'ncat',
       'dnsutils',
   ],
}) %}

install-sys-firewall-packages:
  pkg.installed:
    - pkgs:
      {{ (common_pkgs + release_pkgs) | yaml(False) | indent(6) }}
