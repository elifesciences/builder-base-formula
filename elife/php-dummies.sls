# deploys orcid-dummy, hypothesis-dummy and similar
# must have a web/index.php file

{% for label, configuration in pillar.elife.php_dummies.items() %}
{% set name = label | replace('_', '-') %} 
{{ name }}-repository-reset: 
    # to avoid
    # stderr: fatal: could not set upstream of HEAD to origin/master when it does not point to any branch.
    cmd.run:
        - name: cd /srv/{{ name }} && git checkout master
        - user: {{ pillar.elife.deploy_user.username }}
        - onlyif:
            - test -d /srv/{{ name }}

{{ name }}-repository:
    builder.git_latest:
        - name: {{ configuration['repository'] }}
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: master
        - target: /srv/{{ name }}/
        - force_fetch: True
        - force_checkout: True
        - force_reset: True
        - require:
            - {{ name }}-repository-reset

    file.directory:
        - name: /srv/{{ name }}
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - builder: {{ name }}-repository

    cmd.run:
        - name: git checkout $(cat {{ configuration['pinned_revision_file'] }})
        - cwd: /srv/{{ name }}
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - file: {{ name }}-repository

{{ name }}-composer-install:
    cmd.run:
        {% if pillar.elife.env != 'dev' %}
        - name: composer --no-interaction install --no-suggest --no-dev --classmap-authoritative
        {% else %}
        - name: composer --no-interaction install --no-suggest
        {% endif %}
        - cwd: /srv/{{ name }}/
        - user: {{ pillar.elife.deploy_user.username }}
        - env:
          - COMPOSER_DISCARD_CHANGES: 'true'
        - require:
            - {{ name }}-repository
            - composer

{{ name }}-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/{{ name }}.conf
        - source: salt://elife/config/etc-nginx-sites-enabled-php-dummy.conf
        - template: jinja
        - context:
            name: {{ name }}
            port: {{ configuration['port'] }}
        - require: 
            - {{ name }}-composer-install
        - listen_in:
            - service: nginx-server-service
            - service: php-fpm
{% endfor %}
