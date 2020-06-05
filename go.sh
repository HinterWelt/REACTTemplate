#!/bin/bash
docker-compose -f docker-compose.builder.yml run --rm $1 &
docker-compose up &