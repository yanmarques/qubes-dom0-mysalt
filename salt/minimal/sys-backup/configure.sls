# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

# Init of configuration.
############################################################################################

{%- from 'minimal/utils.sls' import download_repo_from_templatevm %}

{%- set repo_kwargs = {
  'repo': 'yanmarques/qubes-app-borgmatic',
  'target_dir': '/usr/lib',
  'extract_kwargs': [
    {
      'source_hash': 'sha256=2153bbfd8c2965a35d38ec46e8e007c66aa99ea59b1a8e593d239e93ba6d4eff',
    },  
    {
      'user': 'root',
    },
    {  
      'group': 'root',
    },
  ],
  'installers': [
    'chmod +x install.sh',
    './install.sh',
  ],
} %}

install-packages:
  pkg.installed:
    - pkgs:
      - borgbackup
      - borgmatic 

{{ download_repo_from_templatevm(**repo_kwargs) }} 
