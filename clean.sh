#!/bin/bash

rm -f replica-info-*.gpg secure.env users.txt
rm -f *.html sections/*.html
type vagrant > /dev/null 2>&1 && vagrant destroy -f
rm -rf .vagrant
