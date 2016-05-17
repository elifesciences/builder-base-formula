# adding 'elife' to your application's state top.sls file will include all these below

include:
    - base # misc. that really should belong elsewhere (but where?)
    - hostname
    - known-hosts
    - deploy-user
    - backups
    - security
    - logging
