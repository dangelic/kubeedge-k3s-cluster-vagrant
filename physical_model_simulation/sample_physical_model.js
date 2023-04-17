// #### Flow: 
// downstream: sensor -> Node-RED -> MQTT Broker -> phy. Model
// upstream: phy. Model -> MQTT Broker -> Node-RED

const mqtt = require('mqtt');

// MQTT Broker URL

const brokerUrl = process.env.BROKER_URL || 'mqtt://localhost:1883';
// MQTT Topic to subscribe to
const upstreamTopic = process.env.UPSTREAM_TOPIC || 'edgedevice-datastream/machine-1/sensor-collection/upstream';
const downstreamTopic = process.env.DOWNSTREAM_TOPIC || 'edgedevice-datastream/machine-1/sensor-collection/downstream';
// Maximum values for each sensor
const maxValues = {
  temperature: 400,
  pressure: 900,
  humidity: 60,
  vibration: 10
};
// Threshold percentage for anomaly detection
const thresholdPercentage = 20;

// ASCII art title for Anomaly
var asciiTitle = `
     ____  __               _            __   __  ___          __     __
    / __ \\/ /_  __  _______(_)________ _/ /  /  |/  /___  ____/ /__  / /
   / /_/ / __ \\/ / / / ___/ / ___/ __ \`/ /  / /|_/ / __ \\/ __  / _ \\/ /
  / ____/ / / / /_/ (__  ) / /__/ /_/ / /  / /  / / /_/ / /_/ /  __/ /
 /_/   /_/ /_/\\__, /____/_/\\___/\\__,_/_/  /_/  /_/\\____/\\__,_/\\___/_/
             /____/

   _____                       __              ____   ____   ___
  / ___/____ _____ ___  ____  / /__     _   __/ __ \\/ __ \\/ <  /
  \\__ \\/ __ \`/ __ \\__ \\/ __ \\/ / _ \\   | | / / / / // / / / / /
 ___/ / /_/ / / / / / / /_/ / /  __/   | |/ / /_/ // /_/ / / /
/____/\\__,_/_/ /_/ /_/\ ___/_/\\___/     |___/\\____(_)____(_)_/
                    /_/    
`;



// Server version number
const serverVersion = '0.0.1';

// Display max values and threshold percentage
console.log(asciiTitle);
console.log(`Server Version: ${serverVersion}`);
console.log('Max Values are set to:');
for (const sensor in maxValues) {
  if (maxValues.hasOwnProperty(sensor)) {
    console.log(`- ${sensor}: ${maxValues[sensor]}`);
  }
}
console.log(`Threshold Percentage is set to: ${thresholdPercentage}%`);

// Create MQTT client
const client = mqtt.connect(brokerUrl);

// MQTT client connected
client.on('connect', () => {
  console.log('Connected to MQTT broker running on '+brokerUrl);
  // Subscribe to downstream topic
  client.subscribe(downstreamTopic);
});

// MQTT message received
client.on('message', (downstreamTopic, message) => {
  const data = JSON.parse(message.toString());
  console.log(`Received downstream data from ${downstreamTopic}:`, data);
  
  // Loop through each sensor in the received data
  for (const sensor in data) {
    if (data.hasOwnProperty(sensor)) {
      const value = data[sensor];
      const maxValue = maxValues[sensor];
      const diffPercentage = ((value - maxValue) / maxValue) * 100;
      const status = diffPercentage > thresholdPercentage ? 'ALERT' : 'OK';
      
      // Build the JSON payload
      const payload = {
        threshold: thresholdPercentage,
        checked_value: sensor,
        max_value: maxValue,
        deviation: diffPercentage.toFixed(2),
        result: status
      };
      console.log(`Sensor: ${sensor}, Value: ${value}, Max Value: ${maxValue}, Difference: ${diffPercentage.toFixed(2)}%, Status: ${status}!`);
      console.log(`ACTION: Publishing check result upstream to ${upstreamTopic}:`, payload);
      
      // Send message to upstream topic
      client.publish(upstreamTopic, JSON.stringify(payload));
    }
  }
});

// MQTT client error
client.on('error', (error) => {
  console.error('MQTT client error:', error);
});

// MQTT client disconnected
client.on('close', () => {
  console.log('Disconnected from MQTT broker');
});