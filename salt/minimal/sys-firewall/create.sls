# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% from 'minimal/utils.sls' import 
  clone_then_load_appvms, 
  include_when_required,
  include_when_not_required,
  get_default_vm
%}

{% set config = pillar.get('sys-firewall') %}
{%- set default_data = {} %}
{%- do get_default_vm(default_data, 'sys-net', 'netvm') %}

{% set defaults = [
  ['present', 'label', 'green'],
  ['prefs', 'netvm', default_data.netvm],
  ['prefs', 'autostart', True],
  ['prefs', 'provides-network', True],
  ['features', 'enable', ['qubes-firewall']],
] %}

{{ include_when_required('minimal.sys-net.create') }}

{{ clone_then_load_appvms(config, defaults) }}

{{ include_when_not_required('minimal.sys-firewall.finish') }}
