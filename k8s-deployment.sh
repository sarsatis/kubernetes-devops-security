#!/bin/bash

sed -i 's#replace#${IMAGE_REPO}/${NAME}:${VERSION}#g' k8s_deployment_service.yaml
kubectl -n jenkins get deploy ${DEPLOYMENT_NAME} > /dev/null

if [[ $? -ne 0 ]]; then
    echo "deployment ${DEPLOYMENT_NAME} doesnt exists"
    kubectl apply -f -n jenkins k8s_deployment_service.yaml
else
    echo "deployment ${DEPLOYMENT_NAME} exists"
    echo "image name - ${imageName}"
    kubectl -n jenkins set image deploy ${DEPLOYMENT_NAME} ${CONTAINER_NAME}=${IMAGE_REPO}/${NAME}:${VERSION} --record=true
fi