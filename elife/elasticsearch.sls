# help from: 
# * http://www.hackzine.org/deploying-an-elasticsearch-cluster-via-saltstack.html
# * https://bitbucket.org/lskibinski/kibana-logstash-elasticsearch

elasticsearch-repo:
    # this is actually pretty hard to find!
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-repositories.html#_apt
    pkgrepo.managed:
        - humanname: Official Elasticsearch PPA
        - name: deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main
        - dist: stable
        - file: /etc/apt/sources.list.d/elasticsearch.list
        - key_url: http://packages.elasticsearch.org/GPG-KEY-elasticsearch

elasticsearch:
    group:
        - present

    user:
        - present
        - groups:
            - elasticsearch
        - require:
            - group: elasticsearch

    pkg:
        - installed
        - require:
            - pkg: openjdk7-jre
            - pkgrepo: elasticsearch-repo

    service:
        - running
        - enable: True
        - require:
            - pkg: elasticsearch
            - file: /etc/elasticsearch/elasticsearch.yml
            - group: elasticsearch

elasticsearch-config:
    file.managed:
        - name: /etc/elasticsearch/elasticsearch.yml
        - source: salt://elife/config/etc-elasticsearch-elasticsearch.yml
        - user: elasticsearch
        - group: elasticsearch
        - mode: 644
        - template: jinja

elasticsearch-gui:
    cmd.run:
        - cwd: /usr/share/elasticsearch/
        - name: bin/plugin -install mobz/elasticsearch-head
        - require:
            - pkg: elasticsearch
        - unless:
            - test -d /usr/share/elasticsearch/plugins/head

