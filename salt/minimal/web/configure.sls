# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

# Init of configuration.
############################################################################################

{%- from 'minimal/utils.sls' import cmd_with_templatevm_proxy %}

{%- set flathub_pkgs = [
  'com.discordapp.Discord',
] %}

install-web-packages:
  pkg.installed:
    - pkgs:
      - firefox
      - icecat
      - hexchat
      - transmission
      - pulseaudio-qubes
      - pavucontrol
      - thunderbird
      - flatpak

{% load_yaml as add_flathub_remote -%}
name: add-flathub-remote-to-flatpak
command: |
  flatpak remote-add flathub https://flathub.org/repo/flathub.flatpakrepo
{%- endload %}

{{ cmd_with_templatevm_proxy(**add_flathub_remote) }}

{% load_yaml as install_flathub_packages -%}
name: install-flathub-packages
command: |
  flatpak install -y flathub {{ flathub_pkgs | join(' ') }}
{%- endload %}

{{ cmd_with_templatevm_proxy(**install_flathub_packages) }}

