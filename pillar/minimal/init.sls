###############################################################################
# BASE TEMPLATES CONFIGURATION
###############################################################################

base-templates:
  config:
    minimal-pkgs:
      - fedora-30
      - debian-10
      - centos-7
    fromrepo: qubes-templates-cummunity-testing

  after-install:
    - name: qubes-app-print
      cmd: |
        tmpfile=`mktemp` ; \
          curl -Lso $tmpfile https://github.com/yanmarques/qubes-app-print/archive/master.zip ; \
          unzip -d /usr/lib/qubes $tmpfile ; \
          rm -f $tmpfile
        cd /usr/lib/qubes/qubes-app-print-master
        chmod +x install
        ./install client

networked:
  clones:
    - name: fedora-30-networked
      source: fedora-30-minimal

    - name: debian-10-networked
      source: debian-10-minimal

    - name: centos-7-networked
      source: centos-7-minimal

###############################################################################
# SYS-LIKE APPVM CONFIGURATION
###############################################################################

sys-net:
  clone-config:
    name: debian-10-net
    source: debian-10-networked
    apparmor: true

  appvms:
    - name: minimal-sys-net
      prefs:
        - mem: 400
        - maxmem: 0
        - vcpus: 1


sys-firewall:
  clone-config:
    name: centos-7-firewall
    source: centos-7-networked

  appvms:
    - name: minimal-sys-firewall
      prefs:
        - netvm: sys-net
        - mem: 400
        - maxmem: 700


sys-usb:
  templatevm: centos-7-minimal
  # clone-config:
  #   name: centos-7-usb
  #   source: centos-7-minimal

  appvms:
    - name: minimal-sys-usb
      prefs:
        - mem: 300
        - maxmem: 0
        - vcpus: 1


sys-i2p:
  templatevm: debian-10-networked
  # clone-config:
  #   name: debian-10-i2p
  #   source: debian-10-networked

  appvms:
    - name: minimal-sys-i2p
      prefs:
        - mem: 400
        - maxmem: 800


###############################################################################
# WEB APPVM CONFIGURATION
###############################################################################


web:
  clone-config:
    name: fedora-30-web
    source: fedora-30-networked

  appvms:
    - name: minimal-untrusted-browser-dvm
      prefs:
        - template_for_dispvms: true
        - default_dispvm: minimal-untrusted-browser-dvm
        - include_in_backups: false
        - maxmem: 2048
      features:
        - enable:
          - appmenus-dispvm

    - name: minimal-personal-web
      present:
        - label: blue
      prefs:
        - include_in_backups: false
        - maxmem: 2048
        - vcpus: 1
      firewall:
        - action: accept
          dst4: protonmail.com
          proto: tcp
          dstports: 443

    - name: minimal-college-web
      present:
        - label: blue
      prefs:
        - include_in_backups: false
        - maxmem: 2048
        - vcpus: 1
      firewall:
        {% for host in [
            'api.unisul.br',
            'minha.unisul.br',
            'mu.unisul.br',
            'static.unisul.br',
            'www.uaberta.unisul.br',
            ] %}
        - action: accept
          proto: tcp
          dstports: 443
          dst4: {{ host }}
        {% endfor %}

    - name: minimal-work-web
      present:
        - label: blue
      prefs:
        - include_in_backups: false
        - maxmem: 2048
        - vcpus: 1
      firewall:
        - action: accept
          proto: tcp
          dstports: 443
          dst4: github.com

###############################################################################
# NON-NETWORKED APPVM CONFIGURATION
###############################################################################

disconnected:
  clone-config:
    name: debian-10-disconnected
    source: debian-10-minimal

  appvms:
    - name: minimal-personal-vault
      prefs:
        - maxmem: 600

    - name: minimal-college-vault
      prefs:
        - maxmem: 600

    - name: minimal-work-vault
      prefs:
        - maxmem: 600

    - name: minimal-storage
      prefs:
        - maxmem: 2048

    - name: minimal-audio
      prefs:
        - maxmem: 1024
