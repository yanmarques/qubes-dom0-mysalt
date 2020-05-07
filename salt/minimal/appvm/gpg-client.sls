# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- set vaultvm = pillar.get('vaultvm', grains['id'].split('-')[0] + '-vault') %}

install-split-gpg-domain-config-file:
  file.managed:
    - name: /rw/config/gpg-split-domain
    - user: root
    - group: root
    - mode: 644
    - contents: {{ vaultvm }}

install-split-gpg-domain-env-variable:
  file.append:
    - name: /home/user/.bashrc
    - text: export QUBES_GPG_DOMAIN="{{ vaultvm }}"
