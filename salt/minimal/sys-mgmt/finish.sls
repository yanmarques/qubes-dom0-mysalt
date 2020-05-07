# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/utils.sls' import get_default_vm, qubes_prefs %}

{%- set default_data = {} %}
{%- do get_default_vm(default_data, 'sys-mgmt', 'mgmt') %}

{% load_yaml as data -%}
prefs:
  management_dispvm: {{ default_data.mgmt }}
cmd_args:
  - order: last 
{%- endload %}

{{ qubes_prefs(**data) }}
