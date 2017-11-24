#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    echo "Sorry, you are not root."
    exit 1
fi

for name in $(koha-list --email); do
     
    echo "--- $name ---"
    # echo "KohaAdminEmailAddress:"
    echo "SELECT value FROM systempreferences WHERE variable = 'KohaAdminEmailAddress'" | sudo koha-mysql $name | sed -n '2 p'
    # echo "ReplytoDefault:"
    echo "SELECT value FROM systempreferences WHERE variable = 'ReplytoDefault'" | sudo koha-mysql $name | sed -n '2 p'
    # echo "ReturnpathDefault:"
    echo "SELECT value FROM systempreferences WHERE variable = 'ReturnpathDefault'" | sudo koha-mysql $name | sed -n '2 p'

    echo "SELECT branchemail, branchreplyto, branchreturnpath FROM branches" | sudo koha-mysql $name 

# branchemail      | mediumtext   | YES  |     | NULL    |       |
# | branchreplyto    | mediumtext   | YES  |     | NULL    |       |
# | branchreturnpath

done
