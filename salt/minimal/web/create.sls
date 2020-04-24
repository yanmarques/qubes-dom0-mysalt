# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/utils.sls' import clone_then_load_appvms, include_when_required -%}

{% set config = pillar.get('web') %}

{% set defaults = [
  ['present', 'label', 'red'],
] %}

{{ include_when_required('minimal.networked.create') }}

{{ clone_then_load_appvms(config, defaults) }}
