#!/bin/bash

rm -f replica-info-*.gpg secure.env users.txt
type vagrant && vagrant destroy -f
