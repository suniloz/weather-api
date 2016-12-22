#!/bin/bash

if [ -f $APPNAME.zip ]; then
    rm $APPNAME.zip
fi
zip -q -r $APPNAME.zip node_modules *.js* *.conf
