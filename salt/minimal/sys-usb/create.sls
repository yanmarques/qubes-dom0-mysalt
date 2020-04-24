# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/utils.sls' import
  clone_then_load_appvms,
  include_when_required,
  include_when_not_required,
%}

{%- set config = pillar.get('sys-usb') %}

{%- set defaults = [
  ['present', 'label', 'red'],
  ['prefs', 'netvm', ''],
  ['prefs', 'autostart', True],
  ['prefs', 'virt_mode', 'hvm'],
] %}

{{ include_when_required('minimal.base-templates.create') }}

{{ clone_then_load_appvms(config, defaults) }}

{{ include_when_not_required('minimal.sys-usb.finish') }}

# Setup Qubes RPC policy
{% for vm in config.appvms %}
sys-usb-input-proxy-to-{{ vm.name }}:
  file.append:
    - name: /etc/qubes-rpc/policy/qubes.InputMouse
    - text: {{ vm.name }} dom0 {{ vm.get('dom0-proxy-action', 'ask') }},user=root,default_target=dom0
    - require:
      - qvm: {{ vm.name }}
{% endfor %}
