# running service for apache
# helps reduce the amount of duplication between state trees.

apache2-server:
    service.running:
        - name: apache2
        - require: 
            - file: apache2
