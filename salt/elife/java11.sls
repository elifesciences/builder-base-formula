# good for 18.04 and 20.04
# sets java 11 as the system default automatically
# use this to switch around:
#   sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
#                                       /usr/lib/jvm/java-11-openjdk-amd64/bin/java

java11:
    pkg.installed:
        - pkgs: 
            #- openjdk-11-jre-headless
            # a little larger but less likely to cause problems
            - openjdk-11-jdk-headless
