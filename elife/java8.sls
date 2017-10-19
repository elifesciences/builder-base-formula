# Add the oracle jvm ppa, and install java8
# https://launchpad.net/~webupd8team/+archive/ubuntu/java

oracle-ppa:
    pkgrepo.managed:
        - humanname: WebUpd8 Oracle Java PPA repository
        - name: deb http://ppa.launchpad.net/webupd8team/java/ubuntu {{ salt['grains.get']('oscodename') }} main
        - file: /etc/apt/sources.list.d/webupd8team-java.list
        - keyid: EEA14886
        - keyserver: keyserver.ubuntu.com

oracle-license-select:
    debconf.set:
        - name: oracle-java8-installer
        - data:
            'shared/accepted-oracle-license-v1-1': {'type': 'boolean', 'value': 'true'}

oracle-java8-installer:
    #pkg:
    #    - installed
    #    - refresh: True
    #    - require:
    #        - pkgrepo: oracle-ppa
    #        - oracle-license-select

    # temporary workaround because Oracle, licenses and the fact that the whole world software infrastructure is based on a single guy's free time
    # https://stackoverflow.com/questions/46815254/oracle-java8-installer-webupd8-ppa-404-not-found
    # wget http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/jdk1.8.0_152-linux-x64.tar.gz
    cmd.run:
        - name: |
            apt-get install oracle-java8-installer || true
            cd /var/lib/dpkg/info
            sudo sed -i 's|JAVA_VERSION=8u144|JAVA_VERSION=8u152|' oracle-java8-installer.*
            sudo sed -i 's|PARTNER_URL=http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/|PARTNER_URL=http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/|' oracle-java8-installer.*
            sudo sed -i 's|SHA256SUM_TGZ="e8a341ce566f32c3d06f6d0f0eeea9a0f434f538d22af949ae58bc86f2eeaae4"|SHA256SUM_TGZ="218b3b340c3f6d05d940b817d0270dfe0cfd657a636bad074dcabe0c111961bf"|' oracle-java8-installer.*
            sudo sed -i 's|J_DIR=jdk1.8.0_144|J_DIR=jdk1.8.0_152|' oracle-java8-installer.*
            apt-get install oracle-java8-installer || true
        - require:
            - pkgrepo: oracle-ppa
            - oracle-license-select
            
