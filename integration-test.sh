#!/bin/bash

#integration-test.sh

sleep 5s

PORT=$(kubectl -n jenkins get svc ${SERVICE_NAME} -o json | jq .spec.ports[].nodePort)

echo $PORT
echo $APPLICATION_URL:$PORT/$APPLICATION_URI

if [[ ! -z "$PORT" ]];
then

    response=$(curl -s $APPLICATION_URL:$PORT/$APPLICATION_URI)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" $APPLICATION_URL:$PORT/$APPLICATION_URI)

    if [[ "$response" == 100 ]];
        then
            echo "Increment Test Passed"
        else
            echo "Increment Test Failed"
            exit 1;
    fi;

    if [[ "$http_code" == 200 ]];
        then
            echo "HTTP Status Code Test Passed"
        else
            echo "HTTP Status code is not 200"
            exit 1;
    fi;

else
        echo "The Service does not have a NodePort"
        exit 1;
fi;