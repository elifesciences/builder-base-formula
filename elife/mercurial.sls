# install this way rather than with `pkg.installed` as mercurial for 
# Ubuntu 14.04 comes with a transistive dependency on X11

mercurial:
    cmd.run:
        - name: apt-get install mercurial --no-install-recommends -y
        - unless:
            - which hg
