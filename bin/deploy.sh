#!/bin/bash

# upload code to storage container
curl -i -X PUT \
    -u $CREDENTIAL \
    https://$IDENTITY.storage.oraclecloud.com/v1/Storage-$IDENTITY/$APPNAME-container/$APPNAME.zip \
    -T $APPNAME.zip

# determine if application has been deployed earlier
HTTP_STATUS_CODE=`curl -X GET -u $CREDENTIAL -H "X-ID-TENANT-NAME:$IDENTITY"  -s -o /dev/null  -w "%{http_code}" https://apaas.us.oraclecloud.com/paas/service/apaas/api/v1.1/apps/$IDENTITY/$APPNAME `

echo $HTTP_STATUS_CODE
	
if [[ $HTTP_STATUS_CODE == 200 ]] 
then 
	# application already deployed on server, update instead
	DEPLOY_HTTP_METHOD='PUT'
	DEPLOY_URL=https://apaas.us.oraclecloud.com/paas/service/apaas/api/v1.1/apps/$IDENTITY/$APPNAME
else 	
	# application not present on server, deploy application for the first time
	DEPLOY_HTTP_METHOD='POST'
	DEPLOY_URL=https://apaas.us.oraclecloud.com/paas/service/apaas/api/v1.1/apps/$IDENTITY
fi

echo $DEPLOY_HTTP_METHOD
# deploy application to Application Container Cloud
curl -i -X $DEPLOY_HTTP_METHOD  \
    -u $CREDENTIAL \
    -H "X-ID-TENANT-NAME:$IDENTITY" \
    -H "Content-Type: multipart/form-data" \
    -F "name=$APPNAME" \
    -F "runtime=node" \
    -F "subscription=Monthly" \
    -F "archiveURL=$APPNAME-container/$APPNAME.zip" \
    -F "notes=Deployment via cURL" \
    $DEPLOY_URL
