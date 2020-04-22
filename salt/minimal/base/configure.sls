# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

include:
  - update.qubes-vm

{% set common_pkgs = [
    'pciutils',
    'less',
    'psmisc',
    'qubes-core-agent-passwordless-root',
    'gnome-terminal',
    'curl',
    'qubes-core-agent-qrexec',
    'qubes-core-agent-thunar',
    'thunar-volman',
] %}

{% set release_pkgs = {
    'RedHat': [
        'polkit', 
        'vim-minimal',
    ],
    'Debian': [
        'policykit-1', 
        'vim',
    ],
}.get(grains.os_family, []) %}

install-packages:
  pkg.installed:
  - pkgs:
    {% for pkg in common_pkgs + release_pkgs %}
    - {{ pkg }}
    {% endfor %}

install-qubes-app-print:
  cmd.run:
    - name:
      - tmpfile=`mktemp` ; curl -Lso $tmpfile https://github.com/yanmarques/qubes-app-print/archives/master.zip ; unzip -d /usr/lib/qubes $tmpfile ; rm -f $tmpfile 
      - cd /usr/lib/qubes/qubes-app-print-master
      - chmod +x install
      - ./install client
