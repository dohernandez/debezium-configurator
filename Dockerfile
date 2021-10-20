FROM python:3.10.0-slim-bullseye

MAINTAINER Darien Hernandez <dohernandez@gmail.com>

RUN apt-get update \
    && apt-get install -y curl

# Set the working directory to /debezium
WORKDIR /debezium

ENV ENV_PREFIX=DEBEZIUM_CONFIG_

COPY setup .

RUN ["chmod", "+x", "/debezium/initialize.sh"]

ENTRYPOINT ["/debezium/initialize.sh"]