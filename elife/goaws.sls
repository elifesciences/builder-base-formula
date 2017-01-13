go-get-goaws:
    cmd.run:
        - name: go get github.com/p4tin/goaws
        - env:
            - GOPATH: /usr/local
        - require:
            - pkg: golang-go
