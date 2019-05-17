gearman-daemon:
    pkg.installed:
        - pkgs:
            - gearman-job-server
            - gearman-tools

{% if salt['grains.get']('osrelease') == '14.04' %}
# the default Upstart script is broken and ignores /etc/default/gearman
# https://bugs.launchpad.net/ubuntu/+source/gearmand/+bug/1260830/
# replacing would require an additional restart if we modify the configuration
# here, but projects perform the restart by themselves after *they* modify it
gearman-upstart-script:
    file.managed:
        - name: /etc/init/gearman-job-server.conf
        - source: salt://elife/config/etc-init-gearman-job-server.conf
        - require:
            - gearman-daemon

{% else %}

# 16.04+ come with their own systemd file

{% endif %}
