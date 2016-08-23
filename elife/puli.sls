php-composer-1.0:
   cmd.run:
        - name: |
            cp composer composer1.0
            composer1.0 self-update 1.0.3
        - cwd: /usr/local/bin/
        - require:
            - cmd: install-composer
        - unless:
            - which composer1.0

php-puli-latest:
   cmd.run:
        - name: |
            curl https://puli.io/installer | php
            mv puli.phar puli
        - cwd: /usr/local/bin/
        - unless:
            - which puli

