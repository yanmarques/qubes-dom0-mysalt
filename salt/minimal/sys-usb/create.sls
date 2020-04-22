# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% from 'minimal/clonevm.sls' import maybe_clone_vm with context %}
{% from 'qvm/template.jinja' import load %}

{% set config = pillar.get('sys-usb') %}

{{ maybe_clone_vm(config['clone-config']) }}

{% load_yaml as defaults -%}
name: sys-usb
present:
  - template: {{ config['clone-config'].name }}
  - label: red
prefs:
  - netvm: ''
  - virt_mode: hvm
  - autostart: true
  - memory: 300
  - maxmem: 500
  - vcpus: 1
  - pcidevs: {{ salt['grains.get']('pci_usb_devs', []) }}
{% endload %}

{{ load(defaults) }}

# Setup Qubes RPC policy
sys-usb-input-proxy:
  file.append:
    - name: /etc/qubes-rpc/policy/qubes.InputMouse
    - text: sys-usb dom0 ask,user=root,default_target=dom0
