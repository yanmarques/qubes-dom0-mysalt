# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/clonevm.sls' import maybe_clone_vm -%}
{%- from 'qvm/template.jinja' import load -%}

{% set default_port_policy = pillar.get('sys-i2p').get('default-port-policy', 'i2p-client $default allow,target=sys-i2p') %}
{% set default_policy_path = pillar.get('sys-i2p').get('default-policy-path', '/etc/qubes-rpc/policy/qubes.ConnectTCP') %}
{% set default_port_policies = pillar.get('sys-i2p').get('default-port-policies', [
  {
    'port': '7070',
  }, 
  {
   'port': '4444',
  },
]) %}

{% set pillar_port_policies = pillar.get('sys-i2p').get('port-policies', []) %}

{% set config = pillar.get('sys-i2p').get('clone-config') %}
{% do salt.log.error(pillar.get('sys-i2p:clone-config')) %}
{{ maybe_clone_vm(config) }}

{% load_yaml as defaults -%}
name: sys-i2p
present:
  - template: {{ config.name }}
  - label: black
prefs:
  - netvm: ''
  - provides-network: true
  - memory: 400
  - maxmem: 800
  - vcpus: 3
{%- endload %}

{{ load(defaults) }}

# Setup i2p ports
{% for policy_cfg in default_port_policies + pillar_port_policies %}
allow-bind-tcp-port-{{ policy_cfg['port'] }}:
  file.append:
    - name: {{ policy_cfg.get('path', default_policy_path) }}+{{ policy_cfg['port'] }}
    - text: {{ policy_cfg.get('policy', default_port_policy) }}
{% endfor %}

