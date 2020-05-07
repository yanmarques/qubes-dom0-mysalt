# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

# Init of configuration.
################################################################################

install-vault-packages:
  pkg.installed:
    - pkgs:
      - qubes-gpg-split
      - keepassxc

create-autostart-config-directory:
  file.directory:
    - name: /etc/skel/.config/autostart/ 
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

register-ssh-agent-autostart-script:
  file.managed:
    - name: /etc/skel/.config/autostart/ssh-add.desktop 
    - source: /usr/lib/qubes-app-split-ssh-master/ssh-add.desktop_ssh_vault
    - mode: 755
    - onchanges:
      - file: /etc/skel/.config/autostart/ 

register-ssh-agent-rpc:
  file.managed:
    - name: /etc/qubes-rpc/qubes.SshAgent 
    - source: /usr/lib/qubes-app-split-ssh-master/qubes.SshAgent
    - user: root
    - group: root
    - mode: 755
