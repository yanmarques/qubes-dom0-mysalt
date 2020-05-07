# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

install-sys-mgmt-packages:
  pkg.installed:
    - pkgs:
      - qubes-mgmt-salt-vm
