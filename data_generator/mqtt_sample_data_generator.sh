#!/bin/bash

# MQTT Broker Connection Information
broker_address="mqtt.example.com"  # Enter the IP address or hostname of your MQTT broker
broker_port=1883  # The default port for MQTT is 1883
topic="sensor/data"  # The MQTT topic under which the data will be published
qos=0  # The Quality of Service (QoS) level for the messages (0: At most once, 1: At least once, 2: Exactly once)
interval=0.3 # Inteval Messages are generated and published (in s)

# Generate and Publish Sensor Data as MQTT Messages
while true; do
    # Generate random sensor data
    temperature=$(awk -v min=200 -v max=400 'BEGIN{srand(); print rand()*(max-min)+min}')  # Random temperature between 200 and 400 degrees Celsius
    pressure=$(awk -v min=600 -v max=900 'BEGIN{srand(); print int(rand()*(max-min+1)+min)}')  # Random pressure between 600 and 900 hPa
    humidity=$(awk -v min=30 -v max=60 'BEGIN{srand(); print rand()*(max-min)+min}')  # Random humidity between 30% and 60%
    vibration=$(awk -v min=0 -v max=10 'BEGIN{srand(); print rand()*(max-min)+min}')  # Random vibration between 0 and 10 units

    # Prepare data as JSON format
    data='{"temperature": '$temperature', "pressure": '$pressure', "humidity": '$humidity', "vibration": '$vibration'}'

    # Publish MQTT message
    # mosquitto_pub -h $broker_address -p $broker_port -t $topic -q $qos -m "$data"

    echo "[MQTT DATA GENERATOR] Published data on $broker_address:$broker_port -> topic: $topic: $data"

    # Wait for 0.1 second
    sleep $interval
done