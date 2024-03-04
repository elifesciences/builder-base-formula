#!/bin/bash
#
# turns out the easiest way to get the LetsEncrypt client to work when 
# who-knows-what is lurking in the enabled vhosts dir is to just nuke all vhosts,
# restart server, copy in the 80 -> 443 redirect script, request certs and then
# let Salt deal with application vhosts downstream.
#

set -e # everything must succeed

if which nginx &> /dev/null; then
    rm -f /etc/nginx/sites-enabled/*.conf
    ln -s /etc/nginx/sites-available/unencrypted-redirect.conf /etc/nginx/sites-enabled/unencrypted-redirect.conf
    nginx -t # test config is good before restarting
    service nginx restart
fi

if which apache2 &> /dev/null; then
    rm -f /etc/apache2/sites-enabled/*.conf
    ln -s /etc/apache2/sites-available/unencrypted-redirect.conf /etc/apache2/sites-enabled/unencrypted-redirect.conf
    apachectl configtest # test config is good before restarting
    service apache2 restart
fi
