# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'qvm/template.jinja' import load as base_load -%}

# rules are executed as they appears, from index 0 -> ...
# summary of what default rule does:
#   1 - first delete default rule to accept all
#   2 - then add a drop-all rule
#   3 - later allow basic stuff, like DNS and ICMP
{% set default_fw_rules = [
  {
    'command': 'del',
    'action': 'accept',
  },
  {
    'action': 'drop',
  },
  {
    'action': 'accept',
    'specialtarget': 'dns',
    'dst4': '10.139.1.1',
  },
  {
    'action': 'accept',
    'specialtarget': 'dns',
    'dst4': '10.139.1.2',
  },
  {
    'action': 'accept',
    'proto': 'icmp',
    'icmptype': '8',
  },
] %}

# get the flag passed on the command line.
# with this flag, when running from the command line, it will skip requirements
# specified by state files ; just performance concerns.
{%- set should_require = not pillar.get('from_qubes_mysalt', False) %}

{% macro include_when_required(sls_name) %}
{{ _maybe_include(should_require, sls_name) }}
{% endmacro %}

{% macro include_when_not_required(sls_name) %}
{{ _maybe_include(not should_require, sls_name) }}
{% endmacro %}

{% macro _maybe_include(status, sls_name) %}
  {%- if status %}
include:
  - {{ sls_name }}
  {%- endif %}
{% endmacro %}

{% macro maybe_clone_vm(configuration) %}
  {%- if salt['qvm.check'](configuration.name, 'missing').passed() %}

clone-{{ configuration.source }}-template-to-{{ configuration.name }}:
  qvm.clone:
    - name: {{ configuration.name }}
    - source: {{ configuration.source }}
    {%- if should_require %}
    - require:
      - qvm: {{ configuration.source }}
    {%- endif %}
  {%- endif %}
{% endmacro %}

{% macro clone_then_load_appvms(config, list_defaults) %}
  {%- if 'clone-config' in config %}
    {%- set templatevm = config['clone-config'].name %}
    {{ maybe_clone_vm(config['clone-config']) }}
  {%- else %}
    {%- set templatevm = config['templatevm'] %}

    {%- if should_require %}
      # also apply requirements when creating a VM
      {%- do config.update({'require': [{'qvm': templatevm}]}) %}
    {%- endif %}
  {%- endif %}

  # fill config with default values
  {%- for vm in config.appvms %}
    {%- for option in list_defaults %}
      {%- do add_key_dict(vm, *option) %}
    {%- endfor %}

{{ load(templatevm, vm) }}

  {%- endfor %}
{% endmacro %}

{% macro load(templatevm, config) %}
  {%- do add_key_dict(config, 'present', 'template', templatevm) %}
  {%- set vm_was_missing = salt['qvm.check'](config.name, 'missing').passed() %}
  {%- set has_netvm = not config.get('prefs', []).count({'netvm': ''}) %}

# pass parameters to qubes formula
{{ base_load(config) }}

  # ensure vm is new and has network access
  {%- if vm_was_missing and has_netvm %}
{{ qvm_firewall(config) }}
  {% endif %}
{% endmacro %}

{% macro qvm_firewall(config) %}
  # define which rules should be applied
  {%- set all_rules = config.get('firewall', []) %}
  {%- if not config.get('disable-default-fw-rules', False) %}
    {%- set all_rules = default_fw_rules + all_rules %}
  {% endif %}

apply-firewall-rules-to-{{ config.name }}:
  cmd.run:
    - name: |
      {%- for rule in all_rules %}
        {%- set options = [rule.pop('command', 'add')] %}
        {%- for key, value in rule.items() %}
          {%- do options.append('{}={}'.format(key, value)) %}
        {%- endfor %}
       qvm-firewall {{ config.name }} {{ options | join(' ') }}
      {%- endfor %}
{% endmacro %}

{% macro add_key_dict(dict, upper_key, lower_key, new_value) %}
  # get the upper level value
  {%- set new_data = dict.get(upper_key, []) %}

  # insert in a low-priority position, thus allowing to be overrided
  {%- do new_data.insert(0, {lower_key: new_value}) %}

  # update dict in memory with new values
  {%- do dict.update({upper_key: new_data}) %}
{% endmacro %}
