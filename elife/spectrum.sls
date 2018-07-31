# git extension for managing large files like .tif images
git-lfs:
    cmd.run:
        - name: curl -L https://packagecloud.io/github/git-lfs/gpgkey | sudo apt-key add -
        - unless:
            - apt-key list | grep D59097AB

    # https://packagecloud.io/github/git-lfs/install#manual
    pkgrepo.managed:
        - humanname: packagecloud
        - name: deb https://packagecloud.io/github/git-lfs/ubuntu/ trusty main
        - file: /etc/apt/sources.list.d/github_git-lfs.list
        - require:
            - cmd: git-lfs
        - unless:
            - test -e /etc/apt/sources.list.d/github_git-lfs.list

    pkg.installed:
        - name: git-lfs
        - refresh: True
        - require:
            - pkgrepo: git-lfs

# repository of end2end tests
spectrum-project:
    builder.git_latest:
        - name: ssh://git@github.com/elifesciences/elife-spectrum.git
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: master
        - branch: master
        - force_fetch: True
        - force_clone: True
        - force_reset: True
        - force_checkout: True
        - target: /srv/elife-spectrum
        - require:
            - git-lfs
        #- onchanges:
        #    - cmd: spectrum-project

    file.directory:
        - name: /srv/elife-spectrum
        - user: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
        - require:
            - builder: spectrum-project

    cmd.run:
        - name: git lfs install
        - cwd: /srv/elife-spectrum
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - file: spectrum-project

    # provides xmllint for beautifying imported XML
    pkg.installed:
        - pkgs:
          - libxml2-utils

{% if salt['elife.only_on_aws']() %}
spectrum-project-install-ssh-key:
    # for elife-spectrum-private
    file.managed:
        # null locally:
        - name: /tmp/elife-projects-builder.key
        - source: {{ pillar.elife.projects_builder.key or '' }}
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - mode: 600
        - require:
            - spectrum-project

spectrum-project-install-ssh-configuration:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/.ssh/config
        - contents: |
          Host github.com
            User git
            Hostname github.com
            IdentityFile /tmp/elife-projects-builder.key
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - makedirs: True
        - require: 
            - deploy-user

spectrum-project-install:
    cmd.run:
        - name: |
            ./install.sh && rm /tmp/elife-projects-builder.key
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/elife-spectrum
        - env:
            - GIT_IDENTITY: /tmp/elife-projects-builder.key
        - require:
            - spectrum-project-install-ssh-key
            - spectrum-project-install-ssh-configuration
{% endif %}
            
spectrum-log-directory:
    file.directory:
        - name: /var/log/elife-spectrum
        - user: {{ pillar.elife.deploy_user.username }}
        - mode: 755
        - require:
            - spectrum-project
        
spectrum-cleanup-log:
    file.managed:
        - name: /var/log/elife-spectrum/clean.log
        - user: {{ pillar.elife.deploy_user.username }}
        - mode: 644
        - require:
            - file: spectrum-log-directory

spectrum-cleanup-logrotate:
    file.managed:
        - name: /etc/logrotate.d/spectrum
        - source: salt://elife/config/etc-logrotate.d-spectrum
        - require:
            - file: spectrum-cleanup-log

spectrum-configuration:
    file.managed:
        - name: /srv/elife-spectrum/app.cfg
        - source: salt://elife/config/srv-elife-spectrum-app.cfg
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - spectrum-project

spectrum-temporary-folder:
    file.directory:
        - name: {{ pillar.elife.spectrum.tmp }}
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - spectrum-project
