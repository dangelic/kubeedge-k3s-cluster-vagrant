const mqtt = require('mqtt');

// MQTT Broker URL
const brokerUrl = 'mqtt://localhost:1883';
// MQTT Topic to subscribe to
const topic = 'edgedevice-datastream/machine-1/sensor-collection';
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
  _____  _               _           _                    
 |  __ \\\| |             (_)         | |                   
 | |__) | |__  _   _ ___ _  ___ __ _| |                   
 |  ___/| '_ \\| | | / __| |/ __/ _\` | |                   
 | |    | | | | |_| \\__ | | (_| (_| | |                   
 |_|    |_| |_\\__,  |___|_ \\___\\__,_|_|                   
                __/ |                                     
               |___/                                      
  __  __           _      _   _____  ______ __  __  ____  
 |  \\\/  |         | |    | | |  __ \\\/  ____|  \\\/  |/ __ \\ 
 | \\  / | ___   __| | ___| | | |  | | |__  | \\  / | |  | |
 | |\\/| |/ _ \\ / _\` |/ _ | | | |  | |  __| | |\\/| | |  | |
 | |  | | (_) | (_| |  __| | | |__| | |____| |  | | |__| |
 |_|  |_|\\___/ \\__,_|\\___|_| |_____/|______|_|  |_|\\____/ 
          __       ___         ___                        
         /_ |     / _ \        / _ \\                       
 __   __  | |    | | | |     | | | |                      
 \\ \\ / /  | |    | | | |     | | | |                      
  \\ V /   | |_   | |_| |  _  | |_| |                      
   \\_/    |_(_)   \\___/  (_)  \\___/                       
`;



// Server version number
const serverVersion = '1.0.0';

// Display max values and threshold percentage
console.log(asciiTitle);
console.log(`Server Version: ${serverVersion}`);
console.log('Max Values:');
for (const sensor in maxValues) {
  if (maxValues.hasOwnProperty(sensor)) {
    console.log(`- ${sensor}: ${maxValues[sensor]}`);
  }
}
console.log(`Threshold Percentage: ${thresholdPercentage}%`);

// Create MQTT client
const client = mqtt.connect(brokerUrl);

// MQTT client connected
client.on('connect', () => {
  console.log('Connected to MQTT broker running on '+brokerUrl);
  // Subscribe to topic
  client.subscribe(topic);
});

// MQTT message received
client.on('message', (topic, message) => {
  const data = JSON.parse(message.toString());
  console.log(`Received data from ${topic}:`, data);
  
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
      console.log(`ACTION: Publishing check result downstream to edgedevice-datastream/machine-1/sensor-collection:`, payload);
      
      // Send message to downstream topic
      const downstreamTopic = 'edgedevice-datastream/machine-1/sensor-collection/downstream';
      client.publish(downstreamTopic, JSON.stringify(payload));
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