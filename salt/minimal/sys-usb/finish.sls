# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/utils.sls' import get_default_vm %}

{%- set default_data = {} %}
{%- do get_default_vm(default_data, 'sys-usb', 'usbvm') %}

add-usb-devices-to-sys-usb:
  qvm.vm:
    - name: {{ default_data.usbvm }}
    - prefs:
      - pcidevs: {{ salt['grains.get']('pci_usb_devs', []) }}
    - order: last
