# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/utils.sls' import get_default_vm, qubes_prefs %}

{%- set default_data = {} %}
{%- do get_default_vm(default_data, 'sys-net', 'net') %}

add-network-devices-to-sys-net:
  qvm.vm:
    - name: {{ default_data.net }}
    - prefs:
      - pcidevs: {{ salt['grains.get']('pci_net_devs', []) }}
    - order: 20000 

{% load_yaml as data -%}
prefs:
  clockvm: {{ default_data.net }}
cmd_args:
  - order: last 
{%- endload %}

{{ qubes_prefs(**data) }}
