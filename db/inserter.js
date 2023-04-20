const mqtt = require('mqtt');
const Influx = require('influx');

// MQTT broker configurations
const brokers = [
    {
        host: '10.43.11.158',
        port: 1883,
        topic: 'sensor/flow/machine001/downstream'
    },
    {
        host: '10.43.5.4',
        port: 1883,
        topic: 'sensor/flow/machine002/downstream'
    }
];

// InfluxDB configurations
const influx = new Influx.InfluxDB({
    host: 'localhost',
    database: 'sensorflowdb_downstream',
    schema: [
        {
            measurement: 'sensor_data',
            fields: {
                value: Influx.FieldType.FLOAT
            },
            tags: [
                'machine_id',
                'sensor_type'
            ]
        }
    ]
});

// Connect to MQTT brokers
brokers.forEach((broker) => {
    const client = mqtt.connect(`mqtt://${broker.host}:${broker.port}`);
    client.on('connect', () => {
        console.log(`Connected to ${broker.host}:${broker.port}`);
        client.subscribe(broker.topic);
    });

    // Listen to incoming messages
    client.on('message', (topic, message) => {
        console.log(`Received message on ${topic}: ${message}`);
        const data = JSON.parse(message);
        const { temperature, pressure, vibration, humidity } = data;
        const machineId = topic.split('/').pop(); // Extract machine ID from topic
        const timestamp = Date.now() * 10**6; // Convert to nanoseconds

        // Determine the sensor type based on which value is present in the message
        let sensorType, value;
        if (typeof temperature !== 'undefined') {
            sensorType = 'temperature';
            value = temperature;
        } else if (typeof pressure !== 'undefined') {
            sensorType = 'pressure';
            value = pressure;
        } else if (typeof vibration !== 'undefined') {
            sensorType = 'vibration';
            value = vibration;
        } else if (typeof humidity !== 'undefined') {
            sensorType = 'humidity';
            value = humidity;
        } else {
            console.error(`Unknown sensor type for message: ${message}`);
            return;
        }

        // Write data to InfluxDB
        influx.writePoints([
            {
                measurement: 'sensor_data',
                fields: { value },
                tags: { machine_id: machineId, sensor_type: sensorType },
                timestamp: timestamp
            }
        ]).then(() => {
            console.log(`Data written to InfluxDB for machine ${machineId} at ${timestamp}`);
        }).catch((err) => {
            console.error(`Error writing data to InfluxDB: ${err}`);
        });
    });
});
