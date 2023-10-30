#!/bin/bash
sleep 60s

if [[ $(kubectl -n prod rollout status deploy ${DEPLOYMENT_NAME} --timeout 5s) != *"successfully rolled out"* ]]; 
then     
	echo "Deployment ${DEPLOYMENT_NAME} Rollout has Failed"
    kubectl -n prod rollout undo deploy ${DEPLOYMENT_NAME}
    exit 1;
else
	echo "Deployment ${DEPLOYMENT_NAME} Rollout is Success"
fi