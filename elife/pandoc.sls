pandoc:
    file.managed:
        - name: /root/pandoc-2.5-1-amd64.deb
        - source: https://github.com/jgm/pandoc/releases/download/2.5/pandoc-2.5-1-amd64.deb

    cmd.run:
        - name: sudo dpkg -i pandoc-2.5-1-amd64.deb
        - cwd: /root
