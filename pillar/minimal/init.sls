sys-net:
  clone-config:
    name: debian-10-net
    source: debian-10-networked
    apparmor: true

sys-firewall:
  clone-config:
    name: centos-7-firewall
    source: centos-7-networked

sys-usb:
  clone-config:
    name: centos-7-usb
    source: centos-7-minimal

sys-i2p:
  clone-config:
    name: debian-10-i2p
    source: debian-10-networked

web:
  clone-config:
    name: fedora-30-web
    source: fedora-30-networked
