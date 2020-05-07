# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/utils.sls' import clone_then_load_appvms, include_when_required -%}

{%- set config = pillar.get('vault') -%}

{%- set defaults = [
  ['present', 'netvm', ''],
  ['present', 'label', 'black'],
  ['prefs', 'mem', 300],
  ['prefs', 'maxmem', 600],
] -%}

{% set policies = [
  {
    'name': 'kpxc',
    'file': 'qubes.ClipboardPaste',
    'invert': True,
  },
  {
    'name': 'gpg',
    'file': 'qubes.Gpg',
  },
  {
    'name': 'ssh',
    'file': 'qubes.SshAgent',
  },
] %}

{{ include_when_required('minimal.base-templates.state') }}

{{ clone_then_load_appvms(config, defaults) }}

{%- for vm in config.get('appvms', [])%}
  # remove last fragment from name, which generally is vault
  {%- set group = vm.name.split('-')[:-1] | join('-') %}
  {%- for policy in policies %}
    {%- set command = vm.get('policy', {}).get(policy.name, {}).get('command', 'ask,default_target=' + vm.name) %}

configure-{{ policy.name }}-policy-for-{{ vm.name }}:
  file.prepend:
    - name: /etc/qubes-rpc/policy/{{ policy.file }}
    - text: |
        # Default policy for {{ vm.name }} domain
        {%- if policy.get('invert', False) %}
        {{ vm.name }} @tag:{{ group }}-{{ policy.name }} {{ command }} 
        {{ vm.name }} $anyvm deny
        {%- else %}
        @tag:{{ group }}-{{ policy.name }} {{ vm.name }} {{ command }}
        $anyvm {{ vm.name }} deny
        {%- endif %}
    
  {%- endfor %}
{%- endfor %}
