# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- set default_community_pkgs = [
  'centos-7',
] %}

{%- set default_pkgs = [
  'qubes-gpg-split-dom0',
] %}

{%- set templates = pillar.get('base-templates', {}) %}
{%- set pillar_minimal_pkgs = templates.config.get('minimal-pkgs', []) %}
{%- set official_minimal_pkgs = [] %}
{%- set community_minimal_pkgs = [] %}

{%- for pkg in pillar_minimal_pkgs %}
  {%- set minimal_pkg = 'qubes-template-' + pkg + '-minimal' %}

  {% if pkg in default_community_pkgs %}
    {%- do community_minimal_pkgs.append(minimal_pkg) %}
  {% else %}
    {%- do official_minimal_pkgs.append(minimal_pkg) %}
  {% endif %}
{% endfor %}

install-dom0-packages:
  pkg.installed:
    - pkgs:
      {{ default_pkgs | yaml(False) | indent(6) }}

install-official-minimal-base-templates:
  pkg.installed:
    - pkgs:
      {{ official_minimal_pkgs | yaml(False) | indent(6) }}

install-community-minimal-base-templates:
  pkg.installed:
    - pkgs:
      {{ community_minimal_pkgs | yaml(False) | indent(6) }}
    - fromrepo: qubes-templates-community-testing 

{% if 'debian-10' in pillar_minimal_pkgs %}
# while Qubes do not provide a build-in
configure-debian-10-minimal-apparmor:
  qvm.prefs:
    - name: debian-10-minimal
    - kernelopts: nopat apparmor=1 security=apparmor
{% endif %}
