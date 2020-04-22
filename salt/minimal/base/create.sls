# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

install-templates:
  pkg.installed:
    - pkgs:
      - qubes-template-fedora-30-minimal
      - qubes-template-debian-10-minimal
      - qubes-template-centos-7-minimal
    - fromrepo: qubes-templates-cummunity-testing

# while QubesOS do not provide a build-in
configure-debian-apparmor:
  qvm.prefs:
    - name: debian-10-minimal
    - kernelopts: nopat apparmor=1 security=apparmor

