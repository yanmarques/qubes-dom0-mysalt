# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- from 'minimal/utils.sls' import cmd_with_templatevm_proxy %}

{% set default_i2pd_service = '/lib/systemd/system/i2pd.service' %}
{% set templatevm_systemd_condition = 'ConditionPathExists=!/run/qubes/this-is-templatevm' %}

{% if grains.os == 'CentOS' %}
  {% set default_i2pd_service = '/usr' + default_i2pd_service %}
{% endif %}

# see https://i2pd.readthedocs.io/en/latest/user-guide/install/
{% set repo_cmd = {
    'Debian': 'curl -s https://repo.i2pd.xyz/.help/add_repo | sudo bash -s -',
    'Fedora': 'dnf copr -y enable supervillain/i2pd',
    'CentOS': 'curl -so /etc/yum.repos.d/i2pd-epel-7.repo https://copr.fedorainfracloud.org/coprs/supervillain/i2pd/repo/epel-7/supervillain-i2pd-epel-7.repo',
}.get(grains.os) %}

{{ cmd_with_templatevm_proxy('add-i2p-repo', repo_cmd) }}

install-i2pd-package:
  pkg.installed:
    - name: i2pd

disable-i2p-daemon-service:
  service.dead:
    - name: i2pd
    - enable: False 

add-templatevm-service-condition:
  file.line:
    - name: {{ default_i2pd_service }}
    - after: {{ '[Unit]' | regex_escape }}
    - mode: insert
    - backup: true
    - content: {{ templatevm_systemd_condition }}
    - unless:
      - grep -q {{ templatevm_systemd_condition | quote }} {{ default_i2pd_service }}

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
