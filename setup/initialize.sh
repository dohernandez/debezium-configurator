#!/usr/bin/env bash

initialize() {

  echo "===> Building connector from env vars ..."
  python build_config.py | python -m json.tool > connector_config.json

  echo "===> Deploying connector '${CONNECTOR_NAME}' in server '${CONNECTOR_DSN}':"
  sed -e 's/\(.*password.*"\).*\("\)/\1*****\2/g' connector_config.json

  success=1
  attempts=1
  while [ "$success" != "0" ] && [ $attempts -le 10 ]
  do
    sleep 5
    echo "===> [$attempts] Trying to deploy connector ..."
    curl -i -X POST -fsS -o /dev/null \
      -H "Accept:application/json" \
      -H "Content-Type:application/json" \
      -d @connector_config.json \
      "http://${CONNECTOR_DSN}/connectors/"

    success=$?
    attempts=$((attempts+1))
  done

  if [ "$success" == "0" ]
  then
    echo "===> Successfully deployed connector '${CONNECTOR_NAME}'"
  else
    echo "===> Failed to deploy connector '${CONNECTOR_NAME}'"

    exit 1
  fi
}

initialize
