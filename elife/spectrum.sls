git-lfs-ppa-purged:
    pkgrepo.absent:
        - name: packagecloud
    
    file.absent:
        - name: /etc/apt/sources.list.d/github_git-lfs.list
        - require:
            - pkgrepo: git-lfs-ppa-purged

git-lfs:
    cmd.run:
        - cwd: /tmp
        - name: |
            set -ex
            rm -rf ./git-lfs git-lfs.tar.gz
            wget https://github.com/git-lfs/git-lfs/releases/download/v2.10.0/git-lfs-linux-amd64-v2.10.0.tar.gz \
                --quiet \
                --output-document git-lfs.tar.gz
            sha256sum git-lfs.tar.gz | grep ec1513069f2679c4c95d9d7c54fdb4b9d7007cc568578a25e2b2ff30edd93cfd
            mkdir git-lfs
            tar xvzf git-lfs.tar.gz -C git-lfs
            cd git-lfs
            PREFIX=/usr ./install.sh
        - unless:
            - test -e /usr/bin/git-lfs

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
        - runas: {{ pillar.elife.deploy_user.username }}
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
        - name: /home/{{ pillar.elife.deploy_user.username }}/.ssh/elife-projects-builder.key
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
              IdentityFile /home/{{ pillar.elife.deploy_user.username }}/.ssh/elife-projects-builder.key
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - makedirs: True
        - require: 
            - deploy-user

spectrum-project-install:
    cmd.run:
        - name: |
            ./install.sh
        - runas: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/elife-spectrum

spectrum-configuration:
    file.managed:
        - name: /srv/elife-spectrum/app.cfg
        - source: salt://elife/config/srv-elife-spectrum-app.cfg
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - spectrum-project
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

spectrum-temporary-folder:
    file.directory:
        - name: {{ pillar.elife.spectrum.tmp }}
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - spectrum-project
