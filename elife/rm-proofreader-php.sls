proofreader-php-repository:
    file.absent:
        - name: /srv/proofreader-php

srv-bin-folder:
    file.absent:
        - name: /srv/bin

srv-bin-folder-on-path:
    file.absent:
        - name: /etc/profile.d/srv-bin.sh

