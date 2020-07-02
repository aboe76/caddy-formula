# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "caddy/map.jinja" import caddy with context %}
{% set redirect_domains = pillar.redirect_domains|default([]) %}
{% set fqdn = pillar.fqdn|default('deploy.izeni.com') %}

{% if caddy['force_update'] %}
caddy-clean:
  file.directory:
    - name: /etc/caddy
    - clean: true
{% endif %}

caddy-download:
  archive.extracted:
    - name: /etc/caddy
    - source: https://caddyserver.com/download/linux/amd64?plugins={{ caddy['plugins']|join(', ') }}&license={{ caddy['license'] }}
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

caddy-setcap:
  cmd.run:
    - name: setcap 'cap_net_bind_service=+ep' /etc/caddy/caddy
    - unless: getcap /etc/caddy/caddy | grep -q 'cap_net_bind_service+ep'

caddy-identity:
  user.present:
    - name: www-data
    - uid: 33
    - gid: 33

caddy-ssl-dir:
  file.directory:
    - name: /etc/ssl/caddy
    - user: www-data
    - group: www-data
    - mode: 700
    - require:
      - user: caddy-identity

caddy-install-service:
  file.copy:
    - name: /etc/systemd/system/caddy.service
    - source: /etc/caddy/init/linux-systemd/caddy.service
    - user: root
    - group: root
    - mode: 664
    - require:
      - file: caddy-bin
      - cmd: caddy-setcap
      - user: caddy-identity
      - file: caddy-ssl-dir

caddy-root-config:
  file.managed:
    - name: /etc/caddy/Caddyfile
    - source: salt://caddy/files/Caddyfile
    - replace: True
    - follow_symlinks: False

caddy-sites-enabled:
  file.directory:
    - name: /etc/caddy/sites-enabled
    - user: www-data
    - group: www-data
    - dir_mode: 774
    - file_mode: 664
    - recurse:
      - user
      - group
      - mode

{% if caddy['caddyfile'] %}
caddy-caddyfile-exists:
  file.exists:
    - name: {{ caddy['caddyfile'] }}

caddy-symlink-caddyfile:
  file.symlink:
    - name: /etc/caddy/sites-enabled/default
    - target: {{ caddy['caddyfile'] }}
    - force: True
    - backupname: "Caddyfile.previous"
    - user: www-data
    - group: www-data
    - mode: 664
    - require:
      - file: caddy-caddyfile-exists

{% else %}
caddy-default-index:
  file.managed:
    - name: /var/www/index.html
    - source: salt://caddy/files/index.html
    - replace: False

caddy-default-caddyfile:
  file.managed:
    - name: /etc/caddy/sites-enabled/default
    - source: salt://caddy/files/BasicCaddyfile
    - replace: True
    - follow_symlinks: False
    - require:
      - file: caddy-default-index
{% endif %}

{% if redirect_domains %}
caddy-redirect-conf:
  file.managed:
    - name: /etc/caddy/sites-enabled/redirects
    - source: salt://caddy/templates/redirects.conf
    - template: jinja
    - context:
      redirect_domains: "{{ redirect_domains | join(' ') }}"
      fqdn: {{ fqdn }}
{% endif %}
