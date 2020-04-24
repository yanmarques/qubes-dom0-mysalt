# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- set templates = pillar.get('base-templates', {}) %}
{%- set minimal_pkgs = templates.config.get('minimal-pkgs', []) %}

install-base-templates:
  pkg.installed:
    - pkgs:
      {%- for pkg in minimal_pkgs %}
      - qubes-template-{{ pkg }}-minimal
      {%- endfor %}
    {%- if 'fromrepo' in templates.config %}
    - fromrepo: {{ templates.config.fromrepo }}
    {%- endif %}

{% if 'debian-10' in minimal_pkgs %}
# while Qubes do not provide a build-in
configure-debian-10-minimal-apparmor:
  qvm.prefs:
    - name: debian-10-minimal
    - kernelopts: nopat apparmor=1 security=apparmor
{% endif %}
