# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

add-network-devices-to-sys-net:
  qvm.vm:
    - name: {{ pillar.get('sys-net', {}).get('appvms:0', {}).get('name', 'minimal-sys-net') }}
    - prefs:
      - pcidevs: {{ salt['grains.get']('pci_net_devs', []) }}
