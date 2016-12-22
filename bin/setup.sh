#!/bin/bash

curl -i -X PUT \
  -u $CREDENTIAL \
  https://$IDENTITY.storage.oraclecloud.com/v1/Storage-$IDENTITY/$APPNAME-container
