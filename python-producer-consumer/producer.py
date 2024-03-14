import argparse
from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer
import time
from datetime import datetime

def delivery_callback(err, msg):
    if err:
        print(f"Message delivery failed: {err}")
    else:
        print(f"Message delivered to topic {msg.topic()} [{msg.partition()}] at offset {msg.offset()}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Kafka Avro Producer")
    parser.add_argument("--bootstrap-servers", required=True, help="Bootstrap servers for Kafka cluster")
    parser.add_argument("--schema-registry", required=True, help="Schema Registry URL")
    parser.add_argument("--topic", required=True, help="Topic to produce messages to")
    parser.add_argument("--security-protocol", default="SASL_PLAINTEXT", help="Security protocol to use")
    parser.add_argument("--sasl-mechanism", default="SCRAM-SHA-512", help="SASL mechanism to use")
    parser.add_argument("--sasl-username", required=True, help="SASL username")
    parser.add_argument("--sasl-password", required=True, help="SASL password")
    args = parser.parse_args()

    # Define Avro schema for your message
    avro_schema = avro.loads("""
        {
            "type": "record",
            "name": "Message",
            "fields": [
                {"name": "id", "type": "int"},
                {"name": "name", "type": "string"},
                {"name": "created_at", "type": "string"}
            ]
        }
    """)

    # Create AvroProducer configuration
    conf = {
        "bootstrap.servers": args.bootstrap_servers,
        "security.protocol": args.security_protocol,
        "sasl.mechanism": args.sasl_mechanism,
        "sasl.username": args.sasl_username,
        "sasl.password": args.sasl_password,
        "schema.registry.url": args.schema_registry,
    }

    # Create AvroProducer instance
    producer = AvroProducer(conf, default_value_schema=avro_schema)

    for i in range(100000):
        if i % 2 == 0:
            message = {"id": i,"name":"Anvaari","created_at":f"{datetime.now()}"}
        else:
            message = {"id": i,"name":"Mohammad","created_at":""}

        producer.produce(topic=args.topic, value=message, callback=delivery_callback)
        producer.flush()

        time.sleep(0.1)

