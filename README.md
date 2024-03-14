# Kafka Upgrade Simulation

## Overview

This project provides a Docker Compose configuration to set up a test environment for simulating the upgrade of Kafka alongside Schema Registry, Zookeeper, Clickhouse, and Debezium. The environment includes three Kafka instances, three Zookeeper instances, Schema Registry, Kafka UI, two Python-based producers, a Python-based consumer, Clickhouse as a secondary consumer, and Debezium which performs Change Data Capture (CDC) from sample data in Postgres. Each component is configured with SCRAM-SHA-512 authentication and Avro serialization through Schema Registry.

## Services

- **Zookeeper Instances**:
  - Node Names:
    - `zookeeper1`
    - `zookeeper2`
    - `zookeeper3`
  - Role: Coordination between Kafka brokers
  - Version: 3.4.9

- **Kafka Instances**:
  - Node Names:
    - `kafka1`
    - `kafka2`
    - `kafka3`
  - Role: Broker and main component for testing
  - Version:
    - Current: 1.1.1
    - After Upgrade: 3.6.1

- **Kafka Setup User**:
  - Node Name:
    - `kafka-setup-user`
  - Role:
    - This is a middleware container that initializes and exits after performing specific tasks.
    - It creates users with appropriate Access Control Lists (ACLs).
    - You can view the commands in [this entrypoint](./kafka-setup-user/entrypoint.sh)
  - Version: Kafka-1.1.1

- **Kafka Setup Topic**:
  - Node Name:
    - `kafka-setup-topic`
  - Role:
    - This is a middleware container that initializes and exits after performing specific tasks.
    - It creates topics with appropriate configurations.
    - You can view the commands in [this entrypoint](./kafka-setup-topic/entrypoint.sh)
  - Version: Kafka-1.1.1

- **Schema Registry**:
  - Node Name:
    - `schema-registry`
  - Role: Stores Avro schemas
  - Version: 5.5.4

- **Kafka UI**:
  - Node Name:
    - `kafka-ui`
  - Role: UI for monitoring Kafka
  - Version: latest

- **Producers**:
  - Node Name:
    - `producer`
  - Role: Python-based producer which produces 1 message on Kafka every 0.1 seconds
  - Version:
    - `python`: 3.8
    - `confluent-kafka`: latest

- **Postgres Producer**:
  - Node Name:
    - `postgres-producer`
  - Role: Python-based producer which produces 1 message every 0.1 seconds in Postgres
  - Version:
    - `python`: 3.8
    - `psycopg2`: latest

- **Consumer**:
  - Node Name:
    - `consumer`
  - Role: Python-based consumer which consumes messages produced by `producer` on Kafka
  - Version:
    - `python`: 3.8
    - `confluent-kafka`: latest

- **Clickhouse**:
  - Node Name:
    - `clickhouse`
  - Role: Consumer, which consumes data produced by `debezium` and `producer`, and stores them into some tables
  - Version: 22.3.15.33

- **Debezium**:
  - Node Name:
    - `debezium`
  - Role: Producer, which captures changes from `postgres` and produces them on Kafka
  - Version: 1.6.2.Final

- **Submit Connector**:
  - Node Name:
    - `submit-connector`
  - Role:
    - This is a middleware container that initializes and exits after performing specific tasks.
    - It submits a sample Postgres connector.
    - You can view the configuration of this connector in [this JSON file](./submit-connector/register-postgres.json)
  - Version: curl-8.6.0

- **Postgres**:
  - Node Name:
    - `postgres`
  - Role: Database, which contains some sample data. `debezium` captures changes from it, and `postgres-producer` inserts some messages.
  - Version: 1.7.2.Final (from debezium container registry)

## Test Process

  1. **Clone the Repository:**

      ```bash
      git clone <repository-url>
      cd <repository-directory>
      ```

  2. **Create Config files:**

      First, replace your config files with the current ones:
      - Replace `server.properties` of your Kafka with `./kafka/server.properties`
      - Replace `kafka-connect.properties` of your Kafka Connect with `./debezium/kafka-connect.properties`
      - Replace your `schema-registry.properties` with `./schema-registry/schema-registry.properties`
      - Replace your `zoo.cfg` with `./zookeeper/zoo.cfg`

      Run `bash create_configs.sh`. It will create some `.env` files. They will be set as environment variables in containers.

      **Important notes about config creators:**
          - You should install python (at least 3.7)
          - There are four python code for creating configs:
              - For [Zookeeper](./zookeeper/zookeeper_conf_creator.py`)
              - For [Kafka Connect](./debezium/kafka_connect_config_generator.py)
              - For [Schema Registry](./schema-registry/schema_registry_config_creator.py)
              - For [Kafka](./kafka/kafka_env_creator.py)
          - In each of them some needed config are override and other config are converted to appropriate environment variable.
          - There are three list in each code except for `Zookeeper` (because we directly use config file not environment variable):
              - `configs_override`: Dictionary containing configs which need to be override because of test environment
              - `configs_extra`: List of configs which need to be present because of used images
              - `configs_to_ignore`: List of config names which should be ignored
            You can modify them regarding your cases

  3. **Set Up the Services:**

      ```bash
      docker compose up -d --build
      ```

  4. **Wait for Services to Start:**

      Wait a minute for the services to start and initialize. The previous command should exit with no errors.

  5. **Check Kafka UI:**

      Open Kafka UI in a web browser: [http://localhost:7623](http://localhost:7623)
      - View Kafka `test-topic` and `debezium_cdc.inventory.products` topics and confirm the healthiness of producer and consumer.
        - Select `Live Mode`, and you should see incoming messages.
        - Check logs of `consumer`, `producer`, and `postgres-producer` if necessary:
            - `docker compose logs producer`
            - `docker compose logs consumer`
      - View other topics; they should not be empty. If there is an error, you should check the logs of the `debezium` container:
          - `docker compose logs debezium`

  6. **Check Clickhouse Tables:**

      Connect to Clickhouse on port `8129` for `HTTP` (for example, with [DBeaver](https://dbeaver.io/download/)) or on port `9075` for `TCP` (for example, with [ClickHouse Driver](https://clickhouse-driver.readthedocs.io/en/latest/) in Python).
      Then run:

      ```sql
      SELECT * FROM kafka_test.stream_customer;
      SELECT * FROM kafka_test.stream_orders;
      ```

      They should contain some records, and also the number of records in `kafka_test.stream_products` should be increased.

      Also, check Clickhouse error logs by running this command:

      ```bash
      cat clickhouse/log/clickhouse-server.err.log | grep ERROR
      ```

      The result should be empty.

  7. **Prepare Kafka for Upgrade:**

      According to [this guide](https://kafka.apache.org/36/documentation.html#upgrade_3_6_1), if you are not overriding `log.message.format.version`:

      In your Kafka config, you just need to add this to [server.properties](./kafka/server.properties):

        - `inter.broker.protocol.version=1.1.1`
        Then run `python3 kafka/kafka_env_creator.py` and then change `KAFKA_VERSION` in [.env](./.env) to `3.6.1`

  8. **Rolling Upgrade Kafka:**

      **Wait 1 minute after each broker upgrade and check logs of the Kafka container, then do steps `5` and `6` again.**

      ```bash
      sudo docker compose up kafka1 -d --no-deps --build
      docker compose logs kafka1 # Should not contain ERROR
      docker compose logs kafka1 | grep inter.broker.protocol.version # Should be 1.1.1
      docker compose logs kafka1 | grep log.message.format.version # Should be 3.0-IV1

      sudo docker compose up kafka2 -d --no-deps --build
      docker compose logs kafka2 # Should not contain ERROR
      docker compose logs kafka2 | grep inter.broker.protocol.version # Should be 1.1.1
      docker compose logs kafka2 | grep log.message.format.version # Should be 3.0-IV1

      sudo docker compose up kafka3 -d --no-deps --build
      docker compose logs kafka3 # Should not contain ERROR
      docker compose logs kafka3 | grep inter.broker.protocol.version # Should be 1.1.1
      docker compose logs kafka3 | grep log.message.format.version # Should be 3.0-IV1
      ```

  9. **Upgrade `inter.broker.protocol.version`**

      **Important:** Because of [this](https://kafka.apache.org/36/documentation.html#upgrade_10_performance_impact), this is a point of no return; if you upgrade the `inter.broker.protocol.version`, you can't rollback.

      Change `inter.broker.protocol.version` value in [server.properties](./kafka/server.properties) to `3.6.1` and then run `python3 kafka/kafka_env_creator.py`.

  10. **Again Rolling Upgrade Kafka:**

      Repeat step `8`. Don't forget to recheck steps `5` and `6`.

  11. **Final Check:**

      If everything goes well, you have ensured that you can upgrade your Kafka cluster with zero downtime. But if you encountered any errors, you are lucky because you discovered the error before upgrading the production cluster :)

### Troubleshooting

1. There aren't any new messages in the `debezium_cdc.inventory.products` topic:
    1. First, see the logs of the `postgres-producer` by running:

        ```bash
        docker compose logs producer
        ```

        If everything was okay, proceed to the next step. Otherwise, try to troubleshoot it.
    2. First, check the status of the connector by executing this command:

        ```bash
        curl --request GET \
        --url http://localhost:8083/connectors/inventory-connector/status \
        --header 'Accept: application/json' \
        --header 'Content-Type: application/json'
        ```

    3. If the status is `failed`, restart the task with this command:

        ```bash
        curl --request POST \
          --url http://localhost:8083/connectors/inventory-connector/tasks/0/restart \
          --header 'Accept: application/json' \
          --header 'Content-Type: application/json'
        ```

    4. If it didn't work, you should troubleshoot it. Maybe [this page](https://debezium.io/documentation/faq/) can help you.
    5. If it worked, no problem; you don't need to restart all of your connectors in the production environment. Just use [Connector Guardian](https://github.com/snapp-incubator/connector-guardian) and enjoy :)

2. There aren't any new messages in the `test-topic` topic:

    You should see the logs of the `producer` by running:

    ```bash
    docker compose logs producer
    ```

    Search for errors and try to troubleshoot it.

### Clean project directory for new test

#### Easy way

Just run:

```bash
git reset --hard HEAD
```

This will remove all untracked files and also revert all changes.

#### Hard way

Run:

```bash
sudo rm -r zookeeper/zookeeper1 zookeeper/zookeeper2 zookeeper/zookeeper3 clickhouse/data/* clickhouse/log/* kafka/kafka1.env kafka/kafka2.env kafka/kafka3.env schema-registry/schema-registry.env debezium/kafka-connect.env
```

then

```bash
git checkout .
```

This will revert changes and also remove created files during the test.

## Important notes

- With this procedure, we want to demonstrate the approach for upgrading a service with a high number of dependencies. You should modify it according to your case.
- The `bitnami` image for `Kafka 1.1.1` didn't support `SCRAM-SHA-512`, so we need to override [libkafka.sh](./kafka/libkafka.sh)
