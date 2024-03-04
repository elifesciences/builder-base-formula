solr5-install:
    archive.extracted:
        - name: /opt/
        - if_missing: /opt/solr-5.2.1
        - source: https://archive.apache.org/dist/lucene/solr/5.2.1/solr-5.2.1.tgz
        - source_hash: md5=50b87813e33665512c78ab056842c4d3
        - archive_format: tar

    # we want to refer to it as /opt/solr/ and not /opt/apache-solr-x.x.x/
    file.symlink:
        - name: /opt/solr
        - target: /opt/solr-5.2.1
        - require:
            - archive: solr5-install

# not used? the init script is being run as the deploy user
#solr-user:
#    user.present: 
#        - name: solr
#        - groups:
#            - {{ pillar.elife.deploy_user.username }}


solr5-perms:
    file.directory:
        - name: /opt/solr-5.2.1
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - archive: solr5-install

solr5:
    file.managed:
        - name: /etc/init.d/solr
        - source: salt://elife/config/etc-init.d-solr5
        - template: jinja
        - mode: 755
        
    service.running:
        - name: solr
        - enable: True
        - sig: /opt/solr/server/solr
        - require:
            - file: solr5-perms
            - file: solr5
            - pkg: openjdk7-jre

