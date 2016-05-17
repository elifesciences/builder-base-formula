solr4-install:
    archive.extracted:
        - name: /opt/
        - if_missing: /opt/solr-4.10.4
        - source: https://archive.apache.org/dist/lucene/solr/4.10.4/solr-4.10.4.tgz
        - source_hash: md5=8ae107a760b3fc1ec7358a303886ca06
        - archive_format: tar


    # we want to refer to it as /opt/solr/ and not /opt/apache-solr-x.x.x/
    file.symlink:
        - name: /opt/solr
        - target: /opt/solr-4.10.4
        - require:
            - archive: solr4-install

solr4-perms:
    file.directory:
        - name: /opt/solr-4.10.4
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - archive: solr4-install

solr4:
    file.managed:
        - name: /etc/init.d/solr
        - source: salt://elife/config/etc-init.d-solr4
        - template: jinja
        - mode: 755

    service.running:
        - name: solr
        - enable: True
        - sig: /opt/solr
        - require:
            - file: solr4-perms
            - file: solr4
            - pkg: openjdk7-jre
