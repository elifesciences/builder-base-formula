newrelic-nginx-repository:
    file.managed:
        - name: /etc/apt/sources.list.d/newrelic-nginx.list
        - contents: |
            deb http://nginx.org/packages/mainline/debian/ trusty nginx
            deb-src http://nginx.org/packages/mainline/debian/ trusty nginx
        - require:
            - nginx-server-service

nginx-nr-agent:
    pkg.installed:
        - refresh: True 
        - require:
            - newrelic-nginx-repository
    
