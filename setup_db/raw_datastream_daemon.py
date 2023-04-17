import paho.mqtt.client as mqtt
import json
import psycopg2
import threading
 
# MQTT settings
MQTT_BROKER = "10.21.0.199" 
MQTT_PORT = 1883 
MQTT_TOPIC = "sensor-stream-converted"  
 
# PostgreSQL settings
DB_HOST = "localhost" 
DB_PORT = 5432
DB_NAME = "mqtt"
DB_USER = "postgres"
DB_PASSWORD = "postgres"
TABLE_NAME = "mqtt_data_raw" 
 
# MQTT callback function
def on_message(client, userdata, msg):
    try:
        # Convert MQTT payload to JSON
        mqtt_data = json.loads(msg.payload)
 
        # Connect to PostgreSQL
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )
        cursor = conn.cursor()
 
        # Insert MQTT data into PostgreSQL table
        cursor.execute(
            "INSERT INTO {} (data) VALUES (%s)".format(TABLE_NAME),
            (json.dumps(mqtt_data),)
        )
 
        # Commit changes and close connection
        conn.commit()
        cursor.close()
        conn.close()
 
        print("Successfully inserted MQTT data into PostgreSQL table")
    except Exception as e:
        print("Failed to insert MQTT data into PostgreSQL table:", e)
 
# Create MQTT client and connect to broker
client = mqtt.Client()
client.on_message = on_message
client.connect(MQTT_BROKER, MQTT_PORT, 60)
 
# Subscribe to MQTT topic
client.subscribe(MQTT_TOPIC)
 
# Start MQTT loop to receive messages in a separate thread
client.loop_start()
 
# Keep the main thread alive
while True:
    continue 