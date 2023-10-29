#!/bin/bash

sleep 20s

if [[ $(kubectl -n jenkins rollout status deploy ${DEPLOYMENT_NAME} --timeout 5s) != *"successfully rolled out"* ]];
then 
  echo "Deployment ${DEPLOYMENT_NAME} Rollout has failed"
  kubectl -n jenkins rollout undo deploy ${DEPLOYMENT_NAME}
  exit 1;
else
  echo "Deployment ${DEPLOYMENT_NAME} Rollout is success"
fi