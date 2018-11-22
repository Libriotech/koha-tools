#!/bin/bash
 
# Check that the user is root
if [ "$(whoami)" != "root" ]; then
    echo "Sorry, you are not root."
    exit 1
fi
     
for name in $(koha-list --enabled)
do
    echo "-----------"
    koha-plack --restart "$name"
done
