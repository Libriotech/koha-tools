#!/bin/bash

sudo grep -h ServerName /etc/apache2/sites-enabled/*.conf | grep -v admin | grep -v 8080 | cut -d' ' -f5 | uniq
