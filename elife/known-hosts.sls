#
# SSH system-wide known hosts
# ssh-keyscan -t ssh-rsa -H bitbucket.org > key.pub && ssh-keygen -l -f key.pub
#

bitbucket.org:    
    ssh_known_hosts.present:
        - fingerprint: 97:8c:1b:f2:6f:14:6b:5c:3b:ec:aa:46:46:74:7c:40
        - enc: ssh-rsa
        - timeout: 30

github.com:
    ssh_known_hosts.present:
        - fingerprint: 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48
        - enc: ssh-rsa

git.ent.platform.sh:
    ssh_known_hosts.present:
        - fingerprint: 8f:1d:0e:16:ec:00:dd:b2:ad:02:2c:d6:fa:ef:46:91
        - enc: ssh-rsa

/etc/ssh/ssh_known_hosts:
    file.exists:
        - require:
            - ssh_known_hosts: github.com
            - ssh_known_hosts: bitbucket.org
            - ssh_known_hosts: git.ent.platform.sh
