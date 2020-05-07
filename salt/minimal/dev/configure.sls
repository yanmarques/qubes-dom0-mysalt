# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

# Init of configuration.
################################################################################

{% from 'minimal/utils.sls' import cmd_with_templatevm_proxy %}

{%- set jfx_lib_dir = '/usr/lib/jvm/javafx-sdk-11.0.2' %}

install-dev-packages:
  pkg.installed:
    - pkgs:
      - python3-devel
      - python3-pip
      - java-11-openjdk-devel


{%- if salt.file.directory_exists(jfx_lib_dir) %}
{{ cmd_with_templatevm_proxy('download-javafx-sdk', 'curl -so /tmp/openjfx-11.0.2_linux-x64_bin-sdk.zip https://download2.gluonhq.com/openjfx/11.0.2/openjfx-11.0.2_linux-x64_bin-sdk.zip') }}

{{ cmd_with_templatevm_proxy('download-javafx-sdk-checksum', 'curl -so /tmp/openjfx.zip.sha256 https://download2.gluonhq.com/openjfx/11.0.2/openjfx-11.0.2_linux-x64_bin-sdk.zip.sha256') }}

extract-javafx-sdk:
  archive.extracted:
    - name: {{ jfx_lib_dir }}
    - source: /tmp/openjfx-11.0.2_linux-x64_bin-sdk.zip
    - source_hash: /tmp/openjfx.zip.sha256

{%- endif %}

{% if salt['cmd.run']('command -v code') %}
vscode-already-installed:
  test.nop
{% else %}
{{ cmd_with_templatevm_proxy('import-microsoft-gpg-keys', 'rpm --import https://packages.microsoft.com/keys/microsoft.asc') }}

configure-microsoft-repo:
  file.managed:
    - name: /etc/yum.repos.d/vscode.repo
    - user: root
    - group: root
    - mode: 600
    - contents: |
        [code]
        name=Visual Studio Code
        baseurl=https://packages.microsoft.com/yumrepos/vscode
        enabled=1
        gpgcheck=1
        gpgkey=https://packages.microsoft.com/keys/microsoft.asc

install-vscode-package:
  pkg.installed:
    - name: code
    - refresh: True
{% endif %}

{% if salt['cmd.run']('command -v idea') %}
intellij-idea-already-installed:
  test.nop
{% else %}
{% set idea_url = 'https://download.jetbrains.com/idea/ideaIC-2020.1.1.tar.gz' %}

{{ cmd_with_templatevm_proxy('download-intellij-idea', 'curl -so /tmp/ideaIC-2020.1.1.tar.gz ' + idea_url) }}

{{ cmd_with_templatevm_proxy('download-intellij-idea-checksum', 'curl -so /tmp/idea.tar.gz.sha256 ' + idea_url + '.sha256') }}

extract-intellij-idea:
  archive.extracted:
    - name: /opt 
    - source: /tmp/ideaIC-2020.1.1.tar.gz
    - source_hash: /tmp/idea.tar.gz.sha256  
    - requires:
      - download-intellij-idea
      - download-intellij-idea-checksum

run-intellij-first-run:
  cmd.run:
    - name: |
        exec $(find /opt -type f -name idea.sh)
{% endif %}
