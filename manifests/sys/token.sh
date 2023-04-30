#!/bin/sh

MY_TOKEN=$(kubectl get secret $(kubectl get sa my-service-account -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 -d
)

curl -k -H "Authorization: Bearer $MY_TOKEN" https://<api-server>:<port>/api/v1/nodes



