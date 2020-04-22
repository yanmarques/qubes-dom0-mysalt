# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

{% set network_domains = {
    'debian-10-minimal': ['debian-networked'],
    'centos-7-minimal': ['centos-networked'],
    'fedora-30-minimal': ['fedora-networked'],
} %}

{% from 'minimal/clonevm.sls' import maybe_clone_vm %}

{% for source, domains in network_domains.items() %}
    {% for name in domains %}
        {{ maybe_clone_vm(name, source) }}
    {% endfor %}
{% endfor %}
