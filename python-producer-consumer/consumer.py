import argparse
from confluent_kafka import avro, Consumer
from confluent_kafka.avro import AvroConsumer

def consume_messages(consumer):
    try:
        while True:
            msg = consumer.poll(1.0)
            if msg is None:
                continue

            if msg.error():
                print(f"Message consumption error: {msg.error()}")
            else:
                print(f"Consumed message: {msg.value()}")

    except KeyboardInterrupt:
        pass

    finally:
        consumer.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Kafka Avro Consumer")
    parser.add_argument("--bootstrap-servers", required=True, help="Bootstrap servers for Kafka cluster")
    parser.add_argument("--schema-registry", required=True, help="Schema Registry URL")
    parser.add_argument("--topic", required=True, help="Topic to consume messages from")
    parser.add_argument("--group-id", required=True, help="Consumer group ID")
    parser.add_argument("--security-protocol", default="SASL_PLAINTEXT", help="Security protocol to use")
    parser.add_argument("--sasl-mechanism", default="SCRAM-SHA-512", help="SASL mechanism to use")
    parser.add_argument("--sasl-username", required=True, help="SASL username")
    parser.add_argument("--sasl-password", required=True, help="SASL password")
    args = parser.parse_args()

    # Create AvroConsumer configuration
    conf = {
        "bootstrap.servers": args.bootstrap_servers,
        "group.id": args.group_id,
        "auto.offset.reset": "earliest",
        "security.protocol": args.security_protocol,
        "sasl.mechanism": args.sasl_mechanism,
        "sasl.username": args.sasl_username,
        "sasl.password": args.sasl_password,
        "schema.registry.url": args.schema_registry,
    }

    # Create AvroConsumer instance
    consumer = AvroConsumer(conf)

    # Subscribe to the topic
    consumer.subscribe([args.topic])

    consume_messages(consumer)

    print("Consumer closed")
