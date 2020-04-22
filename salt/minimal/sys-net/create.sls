# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% from 'minimal/clonevm.sls' import maybe_clone_vm %}
{% from 'qvm/template.jinja' import load %}

{% set config = pillar.get('sys-net') %}

{{ maybe_clone_vm(config['clone-config']) }}

{% load_yaml as defaults -%}
name: sys-net
present:
  - template: {{ config['clone-config'].name }}
  - label: red
prefs:
  - netvm: ''
  - virt_mode: hvm
  - autostart: true
  - provides-network: true
  - memory: 300
  - maxmem: 600
  - vcpus: 1 
  #- pcidevs: {{ salt['grains.get']('pci_net_devs', []) }}
  {% if config['clone-config'].get('apparmor', false) %}
  - kernelopts: nopat iommu=soft swiotlb=8192 apparmor=1 security=apparmor
  {% endif %}
service:
  - enable:
    - clocksync
{% endload %}

{{ load(defaults) }}
