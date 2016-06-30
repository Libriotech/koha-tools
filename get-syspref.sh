#!/bin/bash

# Check that the user is root
if [ "$(whoami)" != "root" ]; then
  echo "Sorry, you are not root."
  exit 1
fi

die() {
    echo "$@" 1>&2
    exit 1
}

[ "$#" = 1 ] || die "Usage: $0 sysprefname"

for name in $(koha-list); do
  
  echo -n "$name: "
  
  # Output from this next line is two lines: 
  # - First line is just the string "value"
  # - Second line is the actual value we are looking for
  # The sed command gives us just the second line
  echo "SELECT value FROM systempreferences WHERE variable = '$1'" | sudo koha-mysql $name | sed -n '2 p'

done

