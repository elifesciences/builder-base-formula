format-external-volume:
    cmd.run: 
        - name: mkfs -t {{ pillar.elife.external_volume.filesystem }} {{ pillar.elife.external_volume.device }}
        - onlyif:
            # disk exists
            - test -b {{ pillar.elife.external_volume.device }}
        - unless:
            # volume exists and is already formatted
            - file --special-files {{ pillar.elife.external_volume.device }} | grep {{ pillar.elife.external_volume.filesystem }}

mount-point-external-volume:
    file.directory:
        - name: /ext

mount-external-volume:
    mount.mounted:
        - name: /ext
        - device: {{ pillar.elife.external_volume.device }}
        - fstype: {{ pillar.elife.external_volume.device }}
        - mkmnt: True
        - opts:
            - defaults
        - require:
            - format-external-volume
            - mount-point-external-volume
        - onlyif:
            # disk exists
            - test -b {{ pillar.elife.external_volume.device }}
        - unless:
            # mount point already has a volume mounted
            - cat /proc/mounts | grep --quiet --no-messages /ext/


