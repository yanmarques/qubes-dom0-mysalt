# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% from 'minimal/utils.sls'
  import clone_then_load_appvms,
  include_when_required,
  include_when_not_required
%}

{% set config = pillar.get('sys-net') %}

{% set defaults = [
  ['present', 'label', 'red'],
  ['prefs', 'netvm', ''],
  ['prefs', 'virt-mode', 'hvm'],
  ['prefs', 'autostart', True],
  ['prefs', 'mem', 0],
  ['prefs', 'maxmem', 400],
  ['prefs', 'vcpus', 1],
  ['prefs', 'provides-network', True],
  ['service', 'enable', ['clocksync']],
] %}

{% if config.get('apparmor', false) %}
  # assume here that the vm will use HVM virtualization
  {%- do defaults.append([
    'prefs',
    'kernelopts',
    'nopat iommu=soft swiotlb=8192 apparmor=1 security=apparmor'
    ]) %}
{% endif %}

{{ include_when_required('minimal.networked.create') }}

{{ clone_then_load_appvms(config, defaults) }}

{{ include_when_not_required('minimal.sys-net.finish') }}
