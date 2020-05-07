# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{%- set vaultvm = pillar.get('vaultvm', grains['id'].split('-')[0] + '-vault') %}
{%- set repl_vault = '\\1"' + vaultvm + '"' %}

add-rc-local-split-socket:
  cmd.run:
    - cwd: /usr/lib/qubes-app-split-ssh-master
    - name: cat rc.local_client >> /rw/config/rc.local
    - unless:
      - grep -q 'SSH_VAULT_VM' /rw/config/rc.local

# FIXME use file.replace instead
{% for ssh_file in ['/home/user/.bashrc', '/rw/config/rc.local'] %}
replace-ssh-vault-vm-in-{{ ssh_file }}-with-{{ vaultvm }}:
  cmd.run:
    - name: sed -i {{ ('s|\(SSH_VAULT_VM=\)\(.*\)|'+ repl_vault +'|') | quote }} {{ ssh_file }}
    - unless:
      - grep -q {{ 'SSH_VAULT_VM="'+ vaultvm +'"' }} {{ ssh_file }}
{% endfor %}

