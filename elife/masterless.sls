# when running salt masterless, the minion doesn't need to run as a daemon
disable-salt-minion:
    service.dead:
        - name: salt-minion
        - enable: false
        - onlyif:
            # running within vagrant
            - test -d /vagrant

# ensure nobody has ssh access
# this is necessary to ensure those with access don't inadvertently grant access
# to others
#deny_all_access:
#    cmd.run:
#        - name: |
#            echo > /home/elife/.ssh/authorized_keys
#            # bootstrap user is needed to login
#            # masterless environment disables adding any other keys to bootstrap user
#            #echo > /home/ubuntu/.ssh/authorized_keys
