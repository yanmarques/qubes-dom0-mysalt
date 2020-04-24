# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

add-usb-devices-to-sys-usb:
  qvm.vm:
    # get the first sys-usb appvm or minimal-sys-usb by default
    - name: {{ pillar.get('sys-usb', {}).get('appvms:0', {}).get('name', 'minimal-sys-usb') }}
    - prefs:
      - pcidevs: {{ salt['grains.get']('pci_usb_devs', []) }}
