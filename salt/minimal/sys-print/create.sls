# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/utils.sls' import 
  clone_then_load_appvms, 
  include_when_required,
  get_default_vm,
-%}

{%- set config = pillar.get('sys-print') -%}
{%- set default_data = {} %}
{%- do get_default_vm(default_data, 'sys-print', 'sys-print') %}

{%- set defaults = [
  ['present', 'label', 'green'],
  ['prefs', 'maxmem', 1024],
  ['prefs', 'vcpus', 1],
  ['prefs', 'netvm', ''],
  ['prefs', 'template_for_dispvms', True],
  ['features', 'enable', ['appmenus-dispvm']],
] -%}

{{ include_when_required('minimal.base-templates.state') }}

{{ clone_then_load_appvms(config, defaults) }}

configure-print-policy:
  file.prepend:
    - name: /etc/qubes-rpc/policy/qubes.PrintFile
    - text: |
        $anyvm @default allow,target=$dispvm:{{ default_data['sys-print'] }}
