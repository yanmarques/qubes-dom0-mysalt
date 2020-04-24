# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% set common_pkgs = [
    'qubes-core-agent-networking',
    'qubes-core-agent-network-manager',
    'net-tools',
    'nmap',
    'tcpdump',
] %}

{% set release_pkgs = salt['grains.filter_by']({
    'RedHat': [
        'NetworkManager-wifi',
        'network-manager-applet',
        'wireless-tools',
        'notification-daemon',
        'gnome-keyring',
        'nmap-ncat',
        'bind-utils',
    ],
   'Debian': [
       'ncat',
       'dnsutils',
   ],
}) %}

{% if grains.os == 'Fedora' %}
  {% do release_pkgs.append('polkit') %}

install-hardware-support-pkg-group-in-fedora:
  pkg.group_installed:
    - name: hardware-support
{% endif %}

install-sys-net-packages:
  pkg.installed:
    - pkgs:
      {{ (common_pkgs + release_pkgs) | yaml(False) | indent(6) }}
