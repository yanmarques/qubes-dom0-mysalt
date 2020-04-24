# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/utils.sls' import maybe_clone_vm, include_when_required %}

{{ include_when_required('minimal.base-templates.create') }}

{%- for clone_config in pillar.get('networked', {}).get('clones', []) %}
{{ maybe_clone_vm(clone_config) }}
{%- endfor %}
