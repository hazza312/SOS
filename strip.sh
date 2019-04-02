#!/bin/sh
nm $1 | awk '{ print $1" "$3 }' > $1.sym