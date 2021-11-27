# install Ubuntu PDF utilities package 

poppler-utils:
    cmd.run:
        - name: apt-get install poppler-utils -y
        - unless:
            - pdfinfo
