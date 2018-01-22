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
    # original work around, not working anymore: https://stackoverflow.com/questions/46815254/oracle-java8-installer-webupd8-ppa-404-not-found
    # now: https://ubuntuforums.org/showthread.php?t=2374686&page=5&p=13732563#post13732563
    cmd.run:
        - name: |
            apt-get install -y oracle-java8-installer || true
            cd /var/lib/dpkg/info
            sed -i 's|JAVA_VERSION=8u151|JAVA_VERSION=8u162|' oracle-java8-installer.*
            sed -i 's|PARTNER_URL=http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/|PARTNER_URL=http://download.oracle.com/otn-pub/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/|' oracle-java8-installer.*
            sed -i 's|SHA256SUM_TGZ="c78200ce409367b296ec39be4427f020e2c585470c4eed01021feada576f027f"|SHA256SUM_TGZ="68ec82d47fd9c2b8eb84225b6db398a72008285fafc98631b1ff8d2229680257"|' oracle-java8-installer.*
            sed -i 's|J_DIR=jdk1.8.0_151|J_DIR=jdk1.8.0_162|' oracle-java8-installer.*
            apt-get install -y oracle-java8-installer
        - require:
            - pkgrepo: oracle-ppa
            - oracle-license-select
            
