#!/bin/bash

. /opt/container/script/unit-utils.sh

# Check required environment variables and fix the NGINX unit configuration.

checkCommonRequiredVariables

if [ "${WEBHOOK_VERBOSE}" == "true" ]
then
     WEBHOOK_VERBOSE="-verbose"
else
     WEBHOOK_VERBOSE=""
fi

copyUnitConf nginx-unit-webhook > /dev/null

notifyUnitStarted

# Start webhooks.

exec /opt/webhook/webhook -hooks /opt/container/webhooks.json -urlprefix "webhooks" ${WEBHOOK_VERBOSE}
