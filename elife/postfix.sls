postfix-mailserver:
    pkg.installed:
        - pkgs:
            - postfix
            - mailutils # gives us the 'mail' command

    # mailserver only runs in production env to prevent accidental mailouts
    # why is mailserver running in ci ... ?
    {% if pillar.elife.env in ['prod', 'ci'] %}
    service.running:
    {% else %}
    service.dead:
    {% endif %}
        - name: postfix
        - reload: True

#
# debug scripts for testing the sending of mail
#

test-php-mail-script:
    file.managed:
        - name: /opt/send-test-email.php
        - source: salt://elife/config/opt-send-test-email.php

test-bash-mail-script:
    file.managed:
        - name: /opt/send-test-email.sh
        - source: salt://elife/config/opt-send-test-email.sh
