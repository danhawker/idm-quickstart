#!/bin/bash

rm -f replica-info-*.gpg secure.env users.txt
type vagrant > /dev/null 2>&1 && vagrant destroy -f
