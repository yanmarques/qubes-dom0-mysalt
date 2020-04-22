# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% macro maybe_clone_vm(configuration) %}
  {% if salt['qvm.check'](configuration.name, 'missing').passed() %}
clone-{{ configuration.source }}-template:
  qvm.clone:
    - name: {{ configuration.name }}
    - source: {{ configuration.source }}
  {% endif %}
{% endmacro %}
