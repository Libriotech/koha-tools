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

[ "$#" = 1 ] || die "Usage: $0 tablename"

sum=0
for name in $(koha-list --enabled); do
  
  echo -n "$name: "
  
  # Output from this next line is two lines: 
  # - First line is just the string "value"
  # - Second line is the actual value we are looking for
  # The sed command gives us just the second line
  count=$( echo "SELECT COUNT(*) AS count FROM $1" | sudo koha-mysql $name | sed -n '2 p' )
  echo $count
  sum=$(( sum + count ))

done

echo "--------------"
echo "SUM: $sum"
