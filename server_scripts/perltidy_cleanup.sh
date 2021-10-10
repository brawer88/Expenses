#!/bin/bash

FILES="/var/www/html/Wiki/lib/Controllers/*.tdy
/var/www/html/Wiki/lib/Models/*.tdy
/var/www/html/Wiki/lib/Wiki.pm.tdy"

for f in $FILES
do
    rm $f
done


