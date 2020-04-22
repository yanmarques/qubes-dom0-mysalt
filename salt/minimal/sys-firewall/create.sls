# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% from 'minimal/clonevm.sls' import maybe_clone_vm with context %}

{% set config = pillar.get('sys-firewall-clone') %}

{{ maybe_clone_vm(config) }}

{% from 'qvm/template.jinja' import load %}

{% load_yaml as defaults -%}
name: sys-firewall
present:
  - template: {{ config.name }}
  - label: green
prefs:
  - netvm: sys-net
  - autostart: true
  - provides-network: true
  - memory: 400
  - maxmem: 800
  - vcpus: 2
{% endload %}

{{ load(defaults) }}
