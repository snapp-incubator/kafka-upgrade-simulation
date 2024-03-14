#!/bin/bash

set -e

# Create a Connector
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://debezium:8083/connectors/ -d @/register-postgres.json


# If all commands succeed, print success message
echo "Connector created sucessfully"

touch /tmp/kafka-setup-success