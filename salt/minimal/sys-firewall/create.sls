# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% from 'minimal/utils.sls' import clone_then_load_appvms, include_when_required %}

{% set config = pillar.get('sys-firewall') %}

{% set defaults = [
  ['present', 'label', 'green'],
  ['prefs', 'netvm', 'minimal-sys-net'],
  ['prefs', 'autostart', True],
  ['prefs', 'provides-network', True],
  ['features', 'enable', ['sys-firewall']],
] %}

{{ include_when_required('minimal.sys-net.create') }}

{{ clone_then_load_appvms(config, defaults) }}
