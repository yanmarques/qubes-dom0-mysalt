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

# fixes installing wireshark GUI on CentOS, because just wireshark is the cli only
# see https://osqa-ask.wireshark.org/questions/13243/wireshark-command-not-found
{%- if grains.os == 'CentOS' %}
  {%- do release_pkgs.pop('wireshark') %}
  {%- do release_pkgs.append('wireshark-gnome') %}
{%- endif %}

install-sys-firewall-packages:
  pkg.installed:
    - pkgs:
      {{ (common_pkgs + release_pkgs) | yaml(False) | indent(6) }}

allow-default-user-read-interfaces-with-wireshark:
  user.present:
    - name: user
    - groups:
      {{ (salt.user.list_groups('user') + ['wireshark']) | yaml(False) | indent(6) }}
    - require:
      - install-sys-firewall-packages
