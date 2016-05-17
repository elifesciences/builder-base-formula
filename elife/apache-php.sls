# links apache and php together.
# there are cases where we might want php5 installed and configured and no apache
# or vice-versa.

enable-php5-mod:
    cmd.run:
        - name: a2enmod php5
