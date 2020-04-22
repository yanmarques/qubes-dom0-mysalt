# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/clonevm.sls' import maybe_clone_vm -%}
{%- from 'qvm/template.jinja' import load -%}

{% set config = pillar.get('fedora-30-web-clone') %}

{{ maybe_clone_vm(config) -}}

{% load_yaml as defaults %}
name: fedora-30-web
present:
  template: {{ config.name }}
{%- endload %}

{{ load(defaults) }}
