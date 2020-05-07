# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

# Init of configuration.
################################################################################

install-sys-print-packages:
  pkg.installed:
    - pkgs: 
      - system-config-printer
      - system-config-printer-udev
      - libreoffice-writer
      - cups
      - gutenprint-cups

configure-qubes-app-print:
  cmd.run:
    - cwd: /usr/lib/qubes-app-print-master/
    - name: chmod +x install && ./install server
