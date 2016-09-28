# adding 'elife' to your application's state top.sls file will include all these below
# https://docs.saltstack.com/en/latest/ref/states/include.html

include:
    - .base # misc. that really should belong elsewhere (but where?)
    - .hostname
    - .known-hosts
    - .deploy-user
    - .time-correction
    - .backups
    - .security
    - .logging
    {% if salt['elife.only_on_aws']() %}
    - .daily-system-updates
    {% endif %}
    - .environment-name
