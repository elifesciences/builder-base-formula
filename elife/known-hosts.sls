#
# SSH system-wide known hosts
#

bitbucket.org:    
    ssh_known_hosts.present:
        # ssh-keyscan -t ssh-rsa -H bitbucket.org > key.pub && ssh-keygen -l -f key.pub
        - fingerprint: 97:8c:1b:f2:6f:14:6b:5c:3b:ec:aa:46:46:74:7c:40
        - enc: ssh-rsa
        - timeout: 60
        - unless:
            - grep -r "^bitbucket.org," /etc/ssh/ssh_known_hosts

github.com:
    ssh_known_hosts.present:
        - fingerprint: 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48
        - enc: ssh-rsa
        - unless:
            - grep -r "^github.com," /etc/ssh/ssh_known_hosts

gitlab.coko.foundation:
    ssh_known_hosts.present:
        - fingerprint: 39:2f:44:29:cc:9b:c3:d7:4d:2a:25:ca:6f:e4:17:bc
        - enc: ssh-rsa
        - unless:
            - grep -r "^gitlab.coko.foundation," /etc/ssh/ssh_known_hosts

/etc/ssh/ssh_known_hosts:
    file.exists:
        - require:
            - ssh_known_hosts: github.com
            - ssh_known_hosts: bitbucket.org
