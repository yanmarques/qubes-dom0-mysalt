# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% set default_i2pd_service = '/lib/systemd/system/i2pd.service' %}
{% set templatevm_systemd_condition = 'ConditionPathExists=!/run/qubes/this-is-templatevm' %}

# see https://i2pd.readthedocs.io/en/latest/user-guide/install/
{% set repo_cmd = {
    'Debian': 'curl -s https://repo.i2pd.xyz/.help/add_repo | sudo bash -s -',
    'Fedora': 'dnf copr enable supervillain/i2pd',
    'CentOS': 'curl -s https://copr.fedorainfracloud.org/coprs/supervillain/i2pd/
      repo/epel-7/supervillain-i2pd-epel-7.repo -o /etc/yum.repos.d/i2pd-epel-7.repo',
}.get(grains.os) %}

add-r4sas-repo:
  cmd.run:
    - name: |
        {{ repo_cmd | yaml(False) | indent(8) }}

install-i2pd-package:
  pkg.installed:
    - name: i2pd

enable-i2p-daemon-service:
  service.dead:
    - name: i2pd
    - enable: true

add-templatevm-service-condition:
  file.line:
    - name: {{ default_i2pd_service }}
    - after: {{ '[Unit]' | regex_escape }}
    - mode: insert
    - backup: true
    - content: {{ templatevm_systemd_condition }}
    - unless:
      - grep -qv {{ templatevm_systemd_condition | quote }} {{ default_i2pd_service }}

increase-open-fd-limits:
  file.append:
    - name: /etc/security/limits.conf
    - text: i2pd hard nofile 8192

add-i2pd-var-path-bind-dirs:
  file.append:
    - name: /usr/lib/qubes-bind-dirs.d/50_i2pd.conf
    - text:
      - binds+=( '/var/lib/i2pd' )
      - binds+=( '/etc/i2pd' )
