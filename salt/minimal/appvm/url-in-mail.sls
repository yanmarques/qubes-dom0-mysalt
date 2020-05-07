# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

register-disposablevm-default-browser:
  cmd.run:
    - runas: user
    - name: xdg-settings set default-web-browser disposable-browser.desktop

