# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :
#
# Full example file of a pillar configuration 

###############################################################################
# BASE TEMPLATES CONFIGURATION
###############################################################################

base-templates:
  config:
    minimal-pkgs:
      - fedora-30
      - debian-10
      - centos-7


###############################################################################
# SYS-LIKE APPVM CONFIGURATION
###############################################################################

sys-net:
  templatevm: debian-10-minimal

  appvms:
    - name: sys-net
    - name: other-sys-net
      default-net: true # sets this vm as firewall-vm's netvm


sys-firewall:
  templatevm: centos-7-minimal

  appvms:
    - name: sys-firewall
      prefs:
        - mem: 400
        - maxmem: 700
      disable-default-fw-rules: True
    - name: other-sys-firewall
      default-firewall: true # sets this vm qubes netvm
      disable-default-fw-rules: True


sys-usb:
  templatevm: centos-7-minimal

  appvms:
    - name: sys-usb
      dom0-proxy-action: allow # ask by default

    - name: other-sys-usb
      default-usb: true # allows this vm in InputMouse policy


sys-i2p:
  templatevm: centos-7-minimal

  appvms:
    - name: sys-i2p
      port-policy:
        rule: $anyvm sys-i2p deny # i2p-client @default ask,default_target=sys-i2p by default

    - name: sys-anon-i2p
      port-policy:
        tcp-client: i2p-anon-client # i2p-client by default
      prefs:
        - netvm: sys-whonix


sys-print:
  templatevm: centos-7-minimal

  appvms:
    - name: sys-print-dvm
      prefs:
        - default_dispvm: sys-print-dvm

    - name: sys-print-not-dvm
      prefs:
        - template_for_dispvms: false # true by default


sys-mgmt:
  templatevm: debian-10-minimal

  appvms:
    - name: default-mgmt-dvm
      prefs:
        - default_dispvm: default-mgmt-dvm


###############################################################################
# WEB APPVM CONFIGURATION
###############################################################################


web:
  templatevm: fedora-30-minimal
  
  appvms:
    - name: untrusted-browser-dvm
      prefs:
        - template_for_dispvms: true
        - default_dispvm: untrusted-browser-dvm
      features:
        - enable:
          - appmenus-dispvm
      volume: 10G
      disable-default-fw-rules: True
    
    - name: personal-web
      present:
        - label: gray  # red by default
      tags:
        - add:
          - mypasswords-vault-kpxc # see vault section
      https-hosts:
        - my-awesome-https-site.net


###############################################################################
# DISCONNECTED APPVM CONFIGURATION
###############################################################################


disconnected:
  templatevm: debian-10-minimal

  appvms:
    - name: hot-storage
      present:
        - label: blue # black by default
      volume: 20G

    - name: cold-storage
      volume: 70G   


###############################################################################
# DEVELOPMENT AND BACKUP APPVM CONFIGURATION
###############################################################################


dev: 
  clone-config:
   name: fedora-30-dev
   source: fedora-30-minimal

  appvms:
    - name: work-dev
      volume: 20G
      tags:
        - add:
          - ssh-only-ssh
          - gpg-only-gpg

    - name: full-test
      disable-default-fw-rules: true # only way to allow other traffic than https, but also allow everything


sys-backup:
  templatevm: centos-7-minimal
  
  # this below are not being used by now, but should
  # the idea was to configure this as ssh config in a system-wide way
  # ssh-host: alias-used
  # ssh-user: your-ssh-user

  ssh-hostname: your-backup-host.net # adds firewall rule allowing this host on ssh port  
  
  appvms:
    - name: sys-backup
      volume: 50G
      tags:
        - add:
          - ssh-only-ssh
          - mypasswords-kpxc


###############################################################################
# VAULT APPVM CONFIGURATION
###############################################################################


vault:
  templatevm: debian-10-minimal

  appvms:
    - name: gpg-only-vault
      policy:
        kpxc:
          command: deny # actually this means, no clipboard data leaves this vm
        ssh:
          command: deny
        gpg:
          command: allow # ask,default_target=gpg-only-vault will by the default

    - name: ssh-only-vault
      policy:
        kpxc:
          command: deny
        gpg:
          command: deny 

    - name: mypasswords-vault 
      policy:
        kpxc:
          command: ask,default_target=mypasswords-vault # this is useless, because this is already the default
        gpg:
          command: deny
        ssh:
          command: deny
