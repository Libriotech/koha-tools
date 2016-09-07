#!/bin/bash

# Give all enabled instances a full reindexing

for name in $(koha-list --enabled)
do
  koha-rebuild-zebra -f -v "$name"
done
