#
# SSH system-wide known hosts
#

bitbucket.org:    
    ssh_known_hosts.present:
        # ssh-keyscan -t ssh-rsa -H bitbucket.org > key.pub && ssh-keygen -l -f key.pub
        - fingerprint: 97:8c:1b:f2:6f:14:6b:5c:3b:ec:aa:46:46:74:7c:40
        - enc: ssh-rsa
        # ha! https://github.com/saltstack/salt/issues/29335
        # generates a warning despite being in the docs ... ? :(
        # Our version of Salt is too old, requires 2016.3.0
        # https://docs.saltstack.com/en/latest/ref/states/all/salt.states.ssh_known_hosts.html
        #- timeout: 30

github.com:
    ssh_known_hosts.present:
        - fingerprint: 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48
        - enc: ssh-rsa

/etc/ssh/ssh_known_hosts:
    file.exists:
        - require:
            - ssh_known_hosts: github.com
            - ssh_known_hosts: bitbucket.org
