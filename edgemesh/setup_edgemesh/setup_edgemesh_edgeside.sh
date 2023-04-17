#!/bin/bash

# Change values in edgecore.yaml to enable EdgeMesh
# REF: https://edgemesh.netlify.app/guide/edge-kube-api.html#background

#!/bin/bash

# Define the file path
FILE="/etc/kubeedge/config/edgecore.yaml"

# Define the line to insert
# NOTE: Leave the DNS as it is. 169.254.96.16 refers to the standard EdgeMesh DNS and should not be changed.
LINE="        clusterDNS:\n        - 169.254.96.16"

# Insert the line under modules.edged.tailoredKubeletConfig
sed -i "/^\s*tailoredKubeletConfig:/a \ \ \ \ clusterDNS:\n$LINE" "$FILE"

echo "clusterDNS added to $FILE under modules.edged.tailoredKubeletConfig"

# Define the file path
FILE="/etc/kubeedge/config/edgecore.yaml"

# Replace the value of metaServer.enable with "true"
sed -i 's/\(metaServer:\n[[:space:]]*enable: \).*/\1true/' "$FILE"

echo "metaServer.enable set to true in $FILE"


# Check if a valid .json is returned (which is not empty)
curl 127.0.0.1:10550/api/v1/services