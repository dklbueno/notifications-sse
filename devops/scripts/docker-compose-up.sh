#!/bin/bash

if ! command -v docker compose &> /dev/null
then
    echo "The comand docker-compose could not be found. Please, Install docker-compose to run this script!"
    exit
else
    docker compose up -d --build
fi

