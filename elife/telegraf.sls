# https://www.influxdata.com/downloads/
# https://github.com/influxdata/telegraf

{% if pillar.elife.logging.tick.enabled %}
telegraf:
    pkg.installed:
        - sources:
            - telegraf: https://dl.influxdata.com/telegraf/releases/telegraf_1.0.0_amd64.deb
            #md5=fb2ce3bcfd3a08522e898e590c6ac5b3

    file.managed:
        - name: /etc/telegraf/telegraf.conf
        - source: salt://elife/config/etc-telegraf-telegraf.conf
        - template: jinja
        - require:
            - pkg: telegraf

    service.running:
        - enable: True
        - restart: True
        - require:
            - file: telegraf
{% endif %}
            
           
#influxdb:
#    pkg.installed:
#        - sources:
#            - influxdb: https://dl.influxdata.com/influxdb/releases/influxdb_0.13.0_amd64.deb
#
#    service.running:
#        - enable: True
#        - require:
#            - pkg: influxdb

#chronograf:
#    pkg.installed:
#        - sources:
#            - chronograf: https://dl.influxdata.com/chronograf/releases/chronograf_0.13.0_amd64.deb
#
#    service.running:
#        - enable: True
#        - require:
#            - pkg: chronograf
