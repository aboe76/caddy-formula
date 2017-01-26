# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "caddy/map.jinja" import caddy with context %}

caddy-name:
  service.running:
    - name: {{ caddy.service.name }}
    - enable: True
