#!/bin/bash

FILES="/var/www/html/Wiki/lib/Controllers/*
/var/www/html/Wiki/lib/Models/*
/var/www/html/Wiki/lib/Wiki.pm"

for f in $FILES
do
    perltidy $f
done


