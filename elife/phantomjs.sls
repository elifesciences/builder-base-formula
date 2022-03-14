# Get phantomjs (sticking with 1.9 series for now: there is no stable 2.x
# series binary for Linux atm, and as it takes ~ 30 mins to build, so we won't
# do that. DM 23/11/2015)
        
install-phantomjs:
    cmd.run:
        - cwd: /opt/
        - name: |
            set -e
            mkdir phantomjs-1.9.2
            wget https://phantomjs.googlecode.com/files/phantomjs-1.9.2-linux-x86_64.tar.bz2 --continue --quiet
            tar xjf phantomjs-1.9.2-linux-x86_64.tar.bz2 -C phantomjs-1.9.2 --strip-components=1
            ln -sfT /opt/phantomjs-1.9.2/bin/phantomjs /usr/bin/phantomjs
            rm phantomjs-1.9.2-linux-x86_64.tar.bz2
            
        - unless:
            - test -d /opt/phantomjs-1.9.2 # directory exists
