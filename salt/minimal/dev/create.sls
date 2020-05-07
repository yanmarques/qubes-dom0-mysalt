# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/utils.sls' import clone_then_load_appvms, include_when_required -%}

{%- set config = pillar.get('dev') -%}

{%- set defaults = [
  ['present', 'label', 'orange'],
  ['prefs', 'vcpus', 4],
] -%}

{% for vm in config.get('appvms', []) %}
  {%- do vm.update({'firewall': [
    {'action': 'accept', 'dstports': 443, 'proto': 'tcp'},
    {'action': 'accept', 'dstports': 22, 'proto': 'tcp'},
  ]})%}
{% endfor %}

{{ include_when_required('minimal.base-templates.state') }}

{{ clone_then_load_appvms(config, defaults) }}
