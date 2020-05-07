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
{%- set should_require = not pillar.get('from_mysalt_cli', False) %}

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
  {%- set vm_data = {} %}
  {%- do get_templatevm(vm_data, config) %}

  {%- if vm_data.is_cloning %}
    {{ maybe_clone_vm(config['clone-config']) }}  
  {%- elif should_require %}
    # also apply requirements when creating a VM
    {%- do config.update({'require': [{'qvm': vm_data.templatevm}]}) %}
  {%- endif %}

  # fill config with default values
  {%- for vm in config.appvms %}
    {%- for option in list_defaults %}
      {%- do add_key_dict(vm, *option) %}
    {%- endfor %}

{{ load(vm_data.templatevm, vm) }}

  {%- endfor %}
{% endmacro %}

{% macro get_templatevm(ret_data, config) %}
  {%- set is_cloning = 'clone-config' in config %}
  
  {%- if is_cloning %}
    {%- set templatevm = config['clone-config'].source %}
  {%- else %}
    {%- set templatevm = config['templatevm'] %}
  {% endif %}
    
  {%- do ret_data.update({'templatevm': templatevm, 'is_cloning': is_cloning}) %}
{% endmacro %}

{% macro load(templatevm, config) %}
  {%- do add_key_dict(config, 'present', 'template', templatevm) %}
  {%- set vm_was_missing = salt['qvm.check'](config.name, 'missing').passed() %}
  {%- set has_netvm = not config.get('prefs', []).count({'netvm': ''}) %}

# pass parameters to qubes formula
{{ base_load(config) }}

  # ensure vm is new and has network access
  {%- if vm_was_missing %}
{{ qvm_volume_resize(config) }}
    {%- if has_netvm %}
{{ qvm_firewall(config) }}
    {%- endif %}
  {% endif %}
{% endmacro %}

{% macro qvm_volume_resize(config) %}
  {%- if config.get('volume') %}
resize-{{ config.name }}-volume:
  cmd.run:
    - name: qvm-volume resize {{ config.name }}:private {{ config.volume }}
  {%- endif %}
{% endmacro %}

{% macro qvm_firewall(config) %}
  # define which rules should be applied
  {%- set all_rules = config.get('firewall', []) %}
  {%- if not config.get('disable-default-fw-rules', False) %}
    {%- set all_rules = default_fw_rules + all_rules %}
  {% endif %}

  {%- if all_rules %}
apply-firewall-rules-to-{{ config.name }}:
  cmd.run:
    - name: |
      {%- for rule in all_rules -%}
        {%- set options = [rule.pop('command', 'add')] -%}
        {%- for key, value in rule.items() -%}
          {%- do options.append('{}={}'.format(key, value)) -%}
        {%- endfor -%}
        
        {# FIXME for now it re-set the command key with popped value #}
        {# but would be better if the default_fw_rules was constant #}
        {%- do rule.update({'command': options[0]}) -%}
        qvm-firewall {{ config.name }} {{ options | join(' ') }}
      {%- endfor -%}
  {%- endif %}
{% endmacro %}

{% macro add_key_dict(dict, upper_key, lower_key, new_value) %}
  # get the upper level value
  {%- set new_data = dict.get(upper_key, []) %}

  # insert in a low-priority position, thus allowing to be overrided
  {%- do new_data.insert(0, {lower_key: new_value}) %}

  # update dict in memory with new values
  {%- do dict.update({upper_key: new_data}) %}
{% endmacro %}

{% macro cmd_with_templatevm_proxy(name, command) %}
{{ name }}:
  cmd.run:
    - env: 
      - https_proxy: http://127.0.0.1:8082
    - name: |
        {{ command }} 
{% endmacro %}

{% macro download_repo_from_templatevm(
  repo, 
  target_dir, 
  extract_kwargs, 
  installers 
) %}
  {%- set url = 'https://codeload.github.com/' + repo + '/zip/master' -%}
  {%- set file = repo.split('/')[-1] + '-master' -%}
  {%- set target_path = [target_dir, file] | join('/') -%}
  
  {% if salt['file.directory_exists'](target_path) -%}
directory-for-{{ repo }}-repo-already-exists:
  test.nop
  {%- else -%}
    {%- set tmp_file = salt.temp.file() -%}
{{ cmd_with_templatevm_proxy('download-' + file + '-repo', 'curl -so ' + tmp_file + ' ' + url) }}

extract-{{ file }}-repo:
  archive.extracted:
    - name: {{ target_dir }}
    - source: {{ tmp_file }} 
    {{ extract_kwargs | yaml(False) | indent(4) }}
    - archive_format: zip
    - require:
      - download-{{ file }}-repo

install-{{ file }}-repo:
  cmd.run:
    - cwd: {{ target_path }}
    - name: |
        {%- for cmd in installers %}
        {{ cmd }}
        {%- endfor %}
    - require:
      - archive: {{ target_dir }} 

{{ tmp_file }}:
  file.absent
  {% endif %}
{%- endmacro %}

{% macro qubes_prefs(prefs, cmd_args=[]) %}
define-global-qubes-preferences:
  cmd.run:
    - name:
        {% for property, value in prefs.items() %}
        qubes-prefs {{ property }} {{ value }}
        {% endfor %}
  {%- if cmd_args %}
    {{ cmd_args | yaml(False) }}
  {%- endif %}
{% endmacro %}

{% macro get_default_vm(ret_data, section, name) %}
  {%- set appvms = salt['pillar.get'](section + ':appvms', []) %}
  {%- set default = appvms[0].name %}
  {%- set custom_data = {} %}

  {%- for vm in appvms %}
    {%- if vm.get('default-' + name, False) %}
      {%- do custom_data.update({name: vm.name}) %}
    {%- endif %}
  {%- endfor %}
  
  {%- do ret_data.update({name: custom_data.get(name, default)}) %}
{% endmacro %}

