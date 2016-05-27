#
# SSH system-wide known hosts
#

bitbucket.org:    
    ssh_known_hosts.present:
        - fingerprint: 131.103.20.167,131.103.20.168,131.103.20.169,131.103.20.170
        - enc: ssh-rsa

github.com:
    ssh_known_hosts.present:
        - fingerprint: 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48
        - enc: ssh-rsa

/etc/ssh/ssh_known_hosts:
    file:
        - present
        - require:
            - ssh_known_hosts: github.com
            - ssh_known_hosts: gist.github.com
            - ssh_known_hosts: bitbucket.org
