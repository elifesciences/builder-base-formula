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

nginx-nr-agent:
    pkg.installed:
        - refresh: True 
        - require:
            - newrelic-nginx-repository
    
