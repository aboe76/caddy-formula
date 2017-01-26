# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "caddy/map.jinja" import caddy with context %}

caddy-pkg:
  pkg.installed:
    - name: {{ caddy.pkg }}
