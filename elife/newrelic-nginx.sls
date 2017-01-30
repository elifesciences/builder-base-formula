# I don't trust pkgrepo.managed and key_url anymore,
# it never works
newrelic-nginx-repository-key:
    cmd.run:
        - name: |
            wget http://nginx.org/keys/nginx_signing.key
            sudo apt-key add nginx_signing.key

newrelic-nginx-repository:
    file.managed:
        - name: /etc/apt/sources.list.d/newrelic-nginx.list
        - contents: |
            deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx
            deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx
        - require:
            - nginx-server-service
            - newrelic-nginx-repository-key

newrelic-nginx-package:
    pkg.installed:
        - name: nginx-nr-agent
        - refresh: True 
        - require:
            - newrelic-nginx-repository
    
newrelix-nginx-configuration-license:
    file.replace:
        - name: /etc/nginx-nr-agent/nginx-nr-agent.ini
        - pattern: '^newrelic_license_key=.*'
        - repl: 'newrelic_license_key={{ pillar.elife.newrelic.license }}'
        - require: 
            - newrelic-nginx-package

newrelix-nginx-configuration-license:
    file.replace:
        - name: /etc/nginx-nr-agent/nginx-nr-agent.ini
        - pattern: '^newrelic_license_key=.*'
        - repl: 'newrelic_license_key={{ pillar.elife.newrelic.license }}'
        - require: 
            - newrelic-nginx-package

newrelix-nginx-configuration-source:
    file.append:
        - name: /etc/nginx-nr-agent/nginx-nr-agent.ini
        - text:
            - [source1]
            - name=nginx
            - url=http://localhost:8002/nginx_status
        - require: 
            - newrelic-nginx-package

newrelic-nginx-configuration-service:
    service.running:
        - name: nginx-nr-agent
        - restart: True
        - require:
            - newrelic-nginx-configuration-license
            - newrelic-nginx-configuration-source
