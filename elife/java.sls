# DEPRECATED, use java8.sls instead

{% if salt['grains.get']('osrelease') == "14.04" %}

openjdk7-jre:
    pkg.installed:
        - pkgs:
            - openjdk-7-jre-headless
        - refresh: True

openjdk-jre:
    cmd.run:
        - name: echo "alias for deprecated openjdk7-jre"
        - require:
            - openjdk7-jre

{% endif %}
