{% if salt['elife.only_on_aws']() %}
{% set hostname = salt['elife.cfg']('cfn.outputs.DomainName', 'cfn.outputs.IntDomainName', '') %}
{% else %}
{% set hostname = 'dev--' + salt['elife.project_name']() + '.elifesciences.org' %}
{% endif %}

# only set a hostname if we have a public hostname like foo.elifesciences.org

{% if hostname %}
set-hostname:
    cmd.run:
        - name: |
            echo {{ hostname }} > /etc/hostname
            hostname --file /etc/hostname

set-hosts:
    host.present:
        - ip: 127.0.0.1
        - names:
            - localhost
            - {{ hostname }}
{% endif %}
