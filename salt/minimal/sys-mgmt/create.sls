# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% from 'minimal/utils.sls'
  import clone_then_load_appvms,
  include_when_required,
  include_when_not_required
%}

{% set config = pillar.get('sys-mgmt') %}

{% set defaults = [
  ['present', 'label', 'black'],
  ['prefs', 'netvm', ''],
  ['prefs', 'maxmem', 2048],
  ['prefs', 'template_for_dispvms', True],
  ['features', 'add', ['internal']],
] %}

{{ include_when_required('minimal.base-templates.create') }}

{{ clone_then_load_appvms(config, defaults) }}

{{ include_when_not_required('minimal.sys-mgmt.finish') }}
