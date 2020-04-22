# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% set common_pkgs = [
    'qubes-core-agent-networking',
    'net-tools',
    'nmap',
    'git',
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

install-packages:
  pkg.installed:
  - pkgs:
    {% for pkg in common_pkgs + release_pkgs %}
    - {{ pkg }}
    {% endfor %}
