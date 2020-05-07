# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% set templates = pillar.get('base-templates', {}) %}

{% set common_pkgs = [
  'pciutils',
  'less',
  'psmisc',
  'vim',
 
  'qubes-core-agent-passwordless-root',
  'qubes-core-agent-qrexec',
  'qubes-core-agent-thunar',
  'qubes-gpg-split',
  'qubes-core-agent-networking',
  
  'net-tools',
  'nmap',
  'git',  
  'curl',

  'gnome-terminal',
  'man',
  'thunar-volman',
  'unzip',
  'zip',
  'make',
  'file',
] %}

{% set release_pkgs = {
    'RedHat': [
        'polkit',
        'nmap-ncat',
        'bind-utils',
    ],
    'Debian': [
        'policykit-1',
        'ncat',
        'dnsutils',
    ],
}.get(grains.os_family, []) %}

install-minimal-template-packages:
  pkg.installed:
    - pkgs:
      {{ (common_pkgs + release_pkgs) | yaml(False) | indent(6) }}
    - order: 10003    

# FIXME: use file.comment instead
comment-default-usb-device-mountpoint:
  file.replace:
    - name: /etc/fstab
    - pattern: '^(/dev/xvdi.*)(/mnt/removable.*)$'
    - repl: '#\1\2'
    - backup: true

change-usb-mount-points-to-media:
  file.append:
    - name: /etc/fstab
    - text: |
        /dev/xvdi /run/media/user/removable auto noauto,user,rw,noexec,nosuid,nodev 0 0
    - require:
      - comment-default-usb-device-mountpoint


include:
  - update.qubes-vm

