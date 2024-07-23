#!/bin/sh
token=$1
url=$2
project_id=$3
env=$4
var=$5
value=$6

response=$(curl -s -I --globoff --header "PRIVATE-TOKEN: $token" "$url$project_id/variables/$var?filter[environment_scope]=$env" | awk '/^HTTP/ {print $2}')

if [ $response -eq 200 ]; then
    curl --globoff --request PUT --header "PRIVATE-TOKEN: $token" "$url$project_id/variables/$var?value=$value&filter[environment_scope]=$env"
    echo $var is already there, updated the existing value
else
    curl --globoff --request POST --header "PRIVATE-TOKEN: $token" $url$project_id/variables --form key=$var --form value=$value --form environment_scope=$env
    echo $var is not there, creating variable
fi