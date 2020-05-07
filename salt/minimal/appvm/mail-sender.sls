# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

register-mailto-vm-handler:
  cmd.run:
    - runas: user
    - name: xdg-settings set default-url-scheme-handler mailto mailto-vm.desktop
