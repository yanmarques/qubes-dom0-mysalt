# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/utils.sls' import clone_then_load_appvms, include_when_required -%}

{% set config = pillar.get('web') %}

{% set defaults = [
  ['present', 'label', 'red'],
  ['prefs', 'maxmem', 2048],
  ['prefs', 'vcpus', 1],
  ['prefs', 'include_in_backups', False],
] %}

{{ include_when_required('minimal.networked.create') }}

{% for vm in config.appvms %}
  {%- set vm_firewall = vm.get('firewall', []) %}
  {% for host in vm.get('https-hosts', []) %}
    {%- do vm_firewall.append({
      'action': 'accept',
      'dst4': host,
      'proto': 'tcp',
      'dstports': 443,
     }) %}
  {% endfor %}
{% endfor %}

{{ clone_then_load_appvms(config, defaults) }}
