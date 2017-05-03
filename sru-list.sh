#!/bin/bash

# Check that we were invoked by root/sudo
if [ "$(whoami)" != "root" ]; then
    echo "Sorry, you are not root."
    exit 1
fi

for SITE in $( koha-list --enabled ); do
    CONF=/etc/koha/sites/$SITE/koha-conf.xml
    PUBSERV=$( xmlstarlet sel -t -v "yazgfs/listen[@id='publicserver']" $CONF )
    if [ -n "$PUBSERV" ]; then
        IFS=":" && parts=($PUBSERV)
        echo "$SITE: http://${parts[1]}:${parts[2]}/biblio" 
    fi
done
