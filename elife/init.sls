# adding 'elife' to your application's state top.sls file will include all these below
# https://docs.saltstack.com/en/latest/ref/states/include.html

include:
    - .base # misc. that really should belong elsewhere (but where?)
    - .hostname
    - .known-hosts
    - .deploy-user
    - .backups
    - .security
    - .logging
    - .daily-system-updates
