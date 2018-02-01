# global defaults for the 'elife' saltstack formula
# this is the DEFAULT DEVELOPMENT file

elife:
    # deprecated, use pillar.env
    dev: True

    # another more fine grained approach to determining environment
    # production is 'prod' by default 
    # can be overriden per-project by pillar files
    env: dev
    domain: elifesciences.org

    deploy_user:
        username: elife
        email: null
        aws_access: null
        aws_secret: null
        aws_region: us-east-1
        key: null
        github_token: null

    projects_builder:
        key: null
        github_token: null

    bootstrap_user:
        username: vagrant # ubuntu in prod

    ssh_users:
        # username: pubkey
        # (this really is an example public key - no one actually owns it)
        example-user: AAAAB3NzaC1yc2EAAAADAQABAAABAQCi0rsrz3X3+oyp85EG+QOhDEAyhykndH5Zyn91pJevvGeJQSxAWjjKVFywCjHJIyZdgq20eiuTPS0nwWTWeUXndCT9K3p7I5emqcnCpd/rboyLPrsvh8y1Gg0FOB7deY8A554yzCT76WjBqiLShv2xSX5sfvgW7hmg+/oVRql55ua13bnEFvwf0pzPDKkY2cUxqlI16Eco8uI+JvVX5y5xPQUgFATh0enwZ0YBjMsFCe+CIHV5RMGHgKypOnva2UzFdwSl6lP1GHvDlHSMoSYgvNUrUv5AEgKD5zbeQoIALI7z5iyyE+xAOUq9I67PeR5faoU+QzrKqr7HsJ5Vinzp

    # grants known users remote access to project systems
    ssh_access:
        # ssh access is granted to the vagrant/ubuntu (bootstrap user) as well as 
        # the deploy user (elife).
        also_bootstrap_user: True
        # adds keys to deploy user's `~/.ssh/authorized_keys` file
        allowed:
            # per-user access to all instances
            all: []

            # per-user, per-project access

            project1:
                - example-user

        # removes keys. happens *after* allowed
        denied:
            # per-user denied access to all instances
            all: []

            # per-user, per-project denied access
            project1: 
                - example-user

    known_hosts: {}

    backups:
        bucket: elife-app-backups
        # AWS credentials for uploading backups to S3
        s3_access: null 
        s3_secret: null

    webserver:
        username: www-data

    nginx:
        certificate_folder: /etc/certificates

    web_users:
        '':
            # the default 'open secret' .htaccess user/pass
            # useful for hiding from robots and randoms
            username: username
            password: password

        crazy-:
            # the 'crazy' .htaccess file with a random user+pass
            # useful for hiding stuff, even from yourselves
            username: ZWQ5YTZiNzRlZmExZDEzZmZhZDkzYzdm
            password: NjU5YTcyYThlM2Q5NWVlZjYwY2ZjMjRk

    # values that both mysql and psql use
    # 2017-08-04, 'db_root' is deprecated in favour of 'db.root'
    db_root:
        username: root
        password: root
    db:
        root:
            username: root
            password: root
        app:
            name: appdb
            username: appuser
            password: apppass

    postgresql:
        host: '127.0.0.1'
        port: 5432

    redis:
        host: 127.0.0.1
        port: 6379
        persistent: false
        maxmemory: 256

    logging:
        collectd:
            enabled: False
            # where collectd should send it's stats
            # unencrypted! make sure this is internal traffic or tunnelled
            send_host: 192.168.1.2
            send_port: 25826

        # loggly destination for syslog-ng logs
        # https://www.loggly.com/
        loggly: 
            enabled: False
            host: "logs-01.loggly.com"
            port: 514
            token: null

        tick:
            enabled: False
            influx_host: http://localhost:8086
            influx_db: telegraf
            influx_user: null
            influx_password: null

    newrelic:
        enabled: False
        license: 1234567890123456789012345678901234567890
        rest_api_key: null

    # postfix using AWS SES as a backend
    postfix_ses_mail:
        smtp: email-smtp.us-east-1.amazonaws.com # change region to suit
        port: 587  # an *unthrottled* SES port. avoid port 25
        from: null # SES verified 'from' address
        user: null # SES-created IAM username
        pass: null # SES-created IAM password

    jenkins:
        slack:
            channel_hook: http://...
        github:
            token: null
    # hub tool for Github interaction
    hub:
        username: elife
        github:
            user: null
            token: null

    docker:
        username: elifealfreduser
        password: null

    external_volume:
        device: /dev/xvdh
        filesystem: ext4
        directory: /ext

    # these will be created as system users
    # but they will only have permissions for their empty home directory
    ftp_users:
        johndoe:
            username: johndoe
            password: somepassword

    php:
        memory_limit: 64M
        upload_max_filesize: 2M
        post_max_size: 8M
        processes:
            enabled: False
            configuration: {}
                #queue_watch:
                #    folder: /srv/annotations
                #    command: /srv/annotations/bin/console queue:watch
                #    number: 1
                #    [require: some-state]

    php_dummies:
        #orcid_dummy:
        #    repository: https://github.com/elifesciences/orcid-dummy
        #    pinned_revision_file: /srv/profiles/orcid-dummy.sha1
        #    port: 8081 # will add 1 to get an HTTPS port too
        
    uwsgi:
        services: {}
            #profiles:  
            #    folder: /srv/profiles

    aws:
        # projects should provide this
        #access_key_id: AKIAFAKE
        #secret_access_key: fake
        region: us-east-1

    goaws:
        # `localhost` if used from the host
        # `goaws` if only used from other Docker containers
        host: localhost
        queues:
            - hello-world

    sidecars:
        # main image that will be used to extract labels 
        # indicating metadata about the sidecars such as their own tags
        # main: elifesciences/annotations_cli
        containers: {}
            #api_dummy:
            #    image: elifesciences/api-dummy
            #    name: api-dummy
            #    port: 8001
            #    enabled: True

    forced_dns: {}

    coveralls:
        tokens: {}

    spectrum:
        end2end:
            aws:
                access_key_id: null
                secret_access_key: null
                region: null
            bot:
                bucket:
                    input: null
                    eif: null
                    cdn: null
                    archive: null
                    published: null
                    silent_corrections: null
                    packaging: null
                queue:
                    workflow_starter: null
                host: null
            dashboard:
                host: null
                user: null
                password: null
            lax:
                host: null
            api_gateway:
                host: null
                authorization: null
            journal:
                host: null
                cdn_host: null
            journal_cms:
                host: null
                user: null
                password: null
            github:
                article_xml_repository_url: null
            personalised_covers:
                bucket: null
            generic_cdn:
                host: null
            observer:
                host: null
        continuumtest:
            aws:
                access_key_id: null
                secret_access_key: null
                region: null
            bot:
                bucket:
                    input: null
                    eif: null
                    cdn: null
                    archive: null
                    published: null
                    silent_corrections: null
                    packaging: null
                queue:
                    workflow_starter: null
                host: null
            dashboard:
                host: null
                user: null
                password: null
            lax:
                host: null
            api_gateway:
                host: null
                authorization: null
            journal:
                host: null
                cdn_host: null
            journal_cms:
                host: null
                user: null
                password: null
            github:
                article_xml_repository_url: null
            personalised_covers:
                bucket: null
            generic_cdn:
                host: null
            observer:
                host: null
        prod:
            journal:
                host: null
            aws:
                region: us-east-1
            peerscout:
                host: null
                user: null
                password: null
            observer:
                host: null
        tmp: /ext/spectrum-tmp
