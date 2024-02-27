# In case there is an external EBS volume available, 
# this state file will format it and make it available on /ext
# (customizable with pillar.elife.external_volume.directory)
# In Vagrant this falls back to just an empty /ext directory
# on the same device as `/`

format-external-volume:
    # ll: mkfs -t ext4 /dev/nvme1n1
    cmd.run:
        - name: mkfs -t {{ pillar.elife.external_volume.filesystem }} {{ pillar.elife.external_volume.device }}
        - onlyif:
            # disk exists
            - test -b {{ pillar.elife.external_volume.device }}
        - unless:
            # volume exists and is already formatted
            - file --special-files {{ pillar.elife.external_volume.device }} | grep {{ pillar.elife.external_volume.filesystem }}

mount-point-external-volume:
    # ll: mkdir /mnt/nvme1n1
    file.directory:
        - name: {{ pillar.elife.external_volume.directory }}

mount-point-external-volume-existing-data-move-out:
    cmd.run:
        - name: |
            touch {{ pillar.elife.external_volume.directory }}/ping
            if systemctl is-enabled --quiet docker; then systemctl stop docker; fi
            mkdir -p /tmp-ext-contents && mv -v {{ pillar.elife.external_volume.directory }}/* /tmp-ext-contents
        #- onlyif:
        #    # volume exists
        #    - test -b {{ pillar.elife.external_volume.device }}
        #- unless:
        #    # volume is already mounted
        #    - cat /proc/mounts | grep --quiet --no-messages {{ pillar.elife.external_volume.directory }}

mount-external-volume:
    # ll: mount /dev/nvme1n1 /mnt/nvme1n1
    mount.mounted:
        - name: {{ pillar.elife.external_volume.directory }}
        - device: {{ pillar.elife.external_volume.device }}
        - fstype: {{ pillar.elife.external_volume.filesystem }}
        - mkmnt: True
        - opts:
            - defaults
        - require:
            - format-external-volume
            - mount-point-external-volume
            - mount-point-external-volume-existing-data-move-out
        - onlyif:
            # disk exists
            - test -b {{ pillar.elife.external_volume.device }}
        - unless:
            # mount point already has a volume mounted
            - cat /proc/mounts | grep --quiet --no-messages {{ pillar.elife.external_volume.directory }}

# in case the volume has been expanded.
# only supports volumes with no partitions (which is what builder creates)
# - https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/recognize-expanded-volume-linux.html
resize-external-volume-if-needed:
    cmd.run:
        - name: resize2fs {{ pillar.elife.external_volume.device }}
        - onlyif:
            # disk exists
            - test -b {{ pillar.elife.external_volume.device }}
        - require:
            - mount-external-volume

mount-point-external-volume-existing-data-move-in:
    cmd.run:
        - name: |
            mv -v /tmp-ext-contents/* {{ pillar.elife.external_volume.directory }}/ && rm -r /tmp-ext-contents
            if systemctl is-enabled --quiet docker; then systemctl start docker; fi
        - onlyif:
            - test -d /tmp-ext-contents
        - require:
            - mount-point-external-volume-existing-data-move-out
            - mount-external-volume

tmp-directory-on-external-volume:
    file.directory:
        - name: {{ pillar.elife.external_volume.directory }}/tmp
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - require:
            - mount-external-volume
        - require_in:
            # put backups on the ext volume
            - file: new-ubr-config # builder-base-formula.backups

