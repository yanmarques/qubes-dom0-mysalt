# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :    

{%- from 'minimal/utils.sls' import download_repo_from_templatevm -%}

{%- set packages = [
  {
    'repo': 'henn/qubes-app-split-ssh',
    'extract_kwargs': [
      {
        'source_hash': 'sha256=8f753ef016afb91b849b1d2ce0d18a2bdcbfc2fb097b40822aa29fa3ca80a34b',
      },
      {
        'user': 'root',
      },
      {
        'group': 'root',
      },
    ],
    'installers': [
      'cp rc.local_client /etc/skel/split-ssh-rc.local_client',
      'cp /etc/skel/.bashrc /etc/skel/.bashrc.salt-old',
      'cat bashrc_client >> /etc/skel/.bashrc',
      'for file in /etc/skel/.bashrc /etc/skel/split-ssh-rc.local_client; do sed -i "s|\(SSH_VAULT_VM=\)\(.*\)|\\1|" "$file"; done',
    ]
  },
  {
    'repo': 'yanmarques/qubes-app-print',
    'extract_kwargs': [
      {
        'source_hash': 'sha256=37ee0a211a7394315fbbb27a14dc189e750fe1dd749219b9384bb1b709389a24'
      }, 
      {
        'user': 'root'
      }, 
      {
        'group': 'root'
      }, 
    ],
    'installers': [
      'chmod +x install',
      './install client',
    ],
  },
] %}

{%- for pkg in packages %}
  {%- do pkg.setdefault('target_dir', '/usr/lib') %}
{{ download_repo_from_templatevm(**pkg) }}
{%- endfor %}

install-disposable-browser-application:
  file.managed:
    - name: /usr/share/applications/disposable-browser.desktop
    - user: root
    - group: root
    - mode: 644
    - contents: |
       [Desktop Entry]
       Version=1.0
       Name=DisposableVM Browser
       GenericName=Qubes Web Browser
       Exec=qvm-open-in-dvm %u
       Icon=firefox
       Terminal=false
       Type=Application
       MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
       Categories=Network;WebBrowser;
       StartupNotify=true
       X-Desktop-File-Install-Version=0.23

install-mailto-vm-application:
  file.managed:
    - name: /usr/share/applications/mailto-vm.desktop
    - user: root
    - group: root
    - mode: 644
    - contents: |
       [Desktop Entry]
       Version=1.0
       Name=Mailto VM
       GenericName=Qubes Email
       Exec=qvm-open-in-vm @default %u
       Icon=thunderbird
       Terminal=false
       Type=Application
       MimeType=message/rfc822;x-scheme-handler/mailto;
       StartupNotify=true
       Categories=Network;Email;
       X-Desktop-File-Install-Version=0.23
