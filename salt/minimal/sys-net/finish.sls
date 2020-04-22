# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% from'qvm/template.jinja' import load %}

{% load_yaml as defaults -%}
name: sys-net
prefs:
  - pcidevs: {{ salt['grains.get']('pci_net_devs', []) }} 
{%- endload %}

{{ load(defaults) }}
