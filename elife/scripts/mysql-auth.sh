#!/bin/bash
# work around for mysql user grants issues with mysql8+ in 20.04.
# grants given permissions ('grants') to given user, with given password, for given host, on given databases in mysql.
# connects without password as the mysql 'root' user unless a non-local 'connection_host' is given, then 
# it expects *all* 'connection_*' parameters.
# run as the system root user.
# run only on 20.04/MySQL 8
set -exu

{% if connection_host is not defined %}
    {% set connection_host = 'localhost' %}
{% endif %}

mysql{% if connection_host != "localhost" %} --user={{ connection_user }} --password={{ connection_pass }} --host={{ connection_host }} --port={{ connection_port }}{% endif %} << eof
CREATE USER IF NOT EXISTS '{{ user }}'@'{{ host }}' IDENTIFIED BY '{{ pass }}';
GRANT {{ grants }} ON {{ db }} TO '{{ user }}'@'{{ host }}';
eof
