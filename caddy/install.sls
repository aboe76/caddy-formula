# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "caddy/map.jinja" import caddy with context %}

{% if caddy['force_update'] %}
caddy-clean:
  file.directory:
    - name: /etc/caddy
    - clean: true
{% endif %}

caddy-download:
  archive.extracted:
    - name: /etc/caddy
    - source: https://caddyserver.com/download/build?os=linux&arch=amd64&features=
    - archive_format: tar
    - skip_verify: true
    - enforce_toplevel: false
    - user: root
    - group: root
    - if_missing: /etc/caddy/caddy
    {% if caddy['force_update'] %}
    - require:
      - file: caddy-clean
    {% endif %}

caddy-bin:
  file.symlink:
    - name: /usr/local/bin/caddy
    - target: /etc/caddy/caddy
    - require:
      - archive: caddy-download

caddy-ports:
  cmd.run:
    - name: setcap 'cap_net_bind_service=+ep' /etc/caddy/caddy
    - watch:
      - archive: caddy-download

caddy-identity:
  user.present:
    - name: www-data
    - uid: 33
    - gid: 33

caddy-install-service:
  file.copy:
    - name: /etc/systemd/system/caddy.service
    - source: /etc/caddy/init/linux-systemd/caddy.service
    - user: root
    - group: root
    - mode: 0664
    - require:
      - file: caddy-bin

