#!/bin/bash

# Check that the user is root
if [ "$(whoami)" != "root" ]; then
    echo "Sorry, you are not root."
    exit 1
fi

for name in $(koha-list --noplack); do

    koha-plack --enable $name
    sleep 1
    koha-plack --start $name
    sleep 1

done

echo "REMEMBER sudo apache2ctl -t"
echo "REMEMBER sudo service apache2 reload"
