# redirects all incoming traffic on port 80 (except LetsEncrypt) to port 443

upgrade-http-to-https-please:
    file.symlink:
        - name: /etc/nginx/sites-enabled/unencrypted-redirect.conf
        - target: /etc/nginx/sites-available/unencrypted-redirect.conf
        - require:
            - file: redirect-nginx-http-to-https
