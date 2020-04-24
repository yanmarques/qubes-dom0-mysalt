# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

include:
  - update.qubes-vm

{% set templates = pillar.get('base-templates', {}) %}

{% set common_pkgs = [
    'pciutils',
    'less',
    'psmisc',
    'qubes-core-agent-passwordless-root',
    'gnome-terminal',
    'curl',
    'qubes-core-agent-qrexec',
    'qubes-core-agent-thunar',
    'thunar-volman',
] %}

{% set release_pkgs = {
    'RedHat': [
        'polkit',
        'vim-minimal',
    ],
    'Debian': [
        'policykit-1',
        'vim',
    ],
}.get(grains.os_family, []) %}

install-minimal-template-packages:
  pkg.installed:
    - pkgs:
      {{ (common_pkgs + release_pkgs) | yaml(False) | indent(6) }}

{% for event in templates.get('after-install', []) %}
call-after-install-{{ event.name }}:
  cmd.run:
    # use cmd.script with a file
    - name:
        {{ event.cmd | yaml(False) | indent(8) }}
{% endfor %}
