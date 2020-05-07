# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/utils.sls' import clone_then_load_appvms, include_when_required -%}

{%- set config = pillar.get('sys-backup', {}) -%}

{%- set defaults = [
  ['present', 'label', 'gray'],
  ['prefs', 'maxmem', 2048],
  ['prefs', 'vcpus', 4],
] -%}

{%- set default_fw_rule = [
  {
    'action': 'accept',
    'dst4': config['ssh-hostname'],
    'proto': 'tcp',
    'dstports': '22',
  },

] %}

{%- for vm in config.get('appvms', []) %}
  {%- do vm.update({'firewall': default_fw_rule}) %}
{%- endfor %}

{{ include_when_required('minimal.base-templates.state') }}

{{ clone_then_load_appvms(config, defaults) }}
