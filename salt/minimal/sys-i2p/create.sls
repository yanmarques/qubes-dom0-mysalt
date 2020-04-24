# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/utils.sls' import clone_then_load_appvms, include_when_required -%}

{% set config = pillar.get('sys-i2p') %}

{% set default_policy_path = config.get(
  'default-policy-path',
  '/etc/qubes-rpc/policy/qubes.ConnectTCP'
) %}

{% set default_policy_ports = config.get('default-policy-ports', [
  '7070',
  '4444',
] ) %}

{% set defaults = [
  ['present', 'label', 'black'],
  ['prefs', 'provides-network', True],
] %}

{{ include_when_required('minimal.networked.create') }}

{{ clone_then_load_appvms(config, defaults) }}

{% for vm in config.appvms %}
  {% set policy_cfg = vm.get('port-policy', {}) %}

  {% set tcp_client = policy_cfg.get('tcp-client', 'i2p-client') %}

  {% set port_policy = policy_cfg.get(
    'rule',
    tcp_client + ' $default ask,default_target=' + vm.name
  ) %}

  {% set custom_ports = policy_cfg.get('ports', []) %}

  {% for port in default_policy_ports + custom_ports %}
allow-bind-tcp-port-{{ port }}-for-{{ vm.name }}:
  file.append:
    - name: {{ default_policy_path }}+{{ port }}
    - text: {{ port_policy }}
  {% endfor %}
{% endfor %}
