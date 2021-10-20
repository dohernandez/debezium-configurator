# Debezium Connector Deployer Docker Image

A Debezium Connector Deployer Docker Image that is entirely to register via **environment variables** a connector in debezium Kafka Connect; It removes the need to manually POST to the Kafka Connect service’s API to register the connector.

[View on Docker Hub](https://hub.docker.com/r/dohernandez/debezium-connector-deployer)

## Example

See the [example folder](./example) for a Docker compose example. Running `docker-compose up -d` in that directory will spin up
* a single-broker Kafka setup, including Zookeeper
* a Mysql database
* a Debezium connector that monitors the database and publishes changes to Kafka

**Note:**
The examples are based on the Debezium tutorial explained in https://debezium.io/documentation/reference/1.6/tutorial.html

```shell
docker run -it --name dohernandez/debezium-connector-deployer --network=example_default \
  -e CONNECTOR_DSN=connect:8083 \
  -e CONNECTOR_NAME=inventory-connector \
  -e DEBEZIUM_CONFIG_CONNECTOR_CLASS=io.debezium.connector.mysql.MySqlConnector \
  -e DEBEZIUM_CONFIG_TASKS_MAX=1 \
  -e DEBEZIUM_CONFIG_DATABASE_HOSTNAME=mysql \
  -e DEBEZIUM_CONFIG_DATABASE_PORT=3306 \
  -e DEBEZIUM_CONFIG_DATABASE_USER=mysqluser \
  -e DEBEZIUM_CONFIG_DATABASE_PASSWORD=mysqlpw \
  -e DEBEZIUM_CONFIG_DATABASE_ID=184054 \
  -e DEBEZIUM_CONFIG_DATABASE_SERVER_NAME=dbserver1 \
  -e DEBEZIUM_CONFIG_DATABASE_INCLUDE_LIST=inventory \
  -e DEBEZIUM_CONFIG_DATABASE_HISTORY_KAFKA_BOOTSTRAP_SERVERS=kafka:9092 \
  -e DEBEZIUM_CONFIG_DATABASE_HISTORY_KAFKA_TOPIC=schema-changes.inventory \
  debezium-connector-deployer
```
**Output**

```shell
===> Building connector from env vars ...
===> Deploying connector 'inventory-connector' in server 'connect:8083':
{
    "name": "inventory-connector",
    "config": {
        "database.id": "184054",
        "database.password": "*****",
        "database.history.kafka.topic": "schema-changes.inventory",
        "database.user": "mysqluser",
        "database.port": "3306",
        "database.include.list": "inventory",
        "database.history.kafka.bootstrap.servers": "kafka:9092",
        "tasks.max": "1",
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "database.server.name": "dbserver1",
        "database.hostname": "mysql"
    }
}
===> [1] Trying to deploy connector ...
===> Successfully deployed connector 'inventory-connector'
```

## Additional examples

The folder [example folder](./example) contains two more Docker compose examples, one with `dohernandez/debezium-connector-deployer` as part of the services defined in the in **docker-compose** configuration, running `docker-compose -f docker-compose-connector-deployer.yml -d`  and a second with `dohernandez/debezium-connector-deployer` and `provectuslabs/kafka-ui` web UI for Apache Kafka to monitor and manage Apache Kafka clusters, running `docker-compose -f docker-compose-connector-deployer-kafkaui.yml -d`.


### Configuring Debezium

All configuration properties which are typically specified in a Debezium config file can be configured via environment variables. The translation scheme follows the example of Connect, except that the prefix is `DEBEZIUM_CONFIG_`

Example:
* `DEBEZIUM_CONFIG_CONNECTOR_CLASS` translates into `connector.class=...`
* `DEBEZIUM_CONFIG_DATABASE_HOSTNAME` translates into `database.hostname=...`
* `DEBEZIUM_CONFIG_DATABASE_PORT` translates into `database.port=...`
* etc.

> ⚠️ The image is not capable of identifying invalid properties and is thus susceptible to typos. It simply translates the environment variables in accordance with the aforementioned renaming rules.

Additionally, the connector name should be specified via `CONNECTOR_NAME` env var and the connector dsn should be specified via `CONNECTOR_DSN`.

## How it works
Setting up a Kafka connector involves sending an HTTP request to the connector's REST API which is often done as a manual step. The API takes the config and stores it in a log-compacted Kafka topic. Connectors are therefore inherently stateful and their deployment is a pain to automate.

This image tries to alleviate this by making the connector configurable through environment variables. When the image starts it builds a deployable file from the specified environment variables and POST it to the API. This is an idempotent operation=the first request will set up a new connector, and all subsequent requests will fail. As a result, starting the container several times with the same configuration will fail with `409 Conflict`. The image will always try 10 times before fails.

