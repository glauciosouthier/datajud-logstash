#!/bin/bash
#set -eu
#set -o pipefail

URL=$1
echo "$URL"
test=$(curl -GET --write-out '%{http_code}' -s --output /dev/null ${URL})
echo "$test"

if [["$test" == "200"]]; then 
echo "delete index ${URL}" && $(curl -X DELETE -s ${URL})
fi

echo "creare index ${URL}" &&\

curl -X PUT -s -H "accept: application/json" -H "Content-Type: application/json" "${URL}"

echo "creare _mapping for ${URL}" 
#    curl -X PUT -v  -H 'Content-Type: application/json' -d "@~/git/datajud/Logstash/mapping.json" "${URL}/_mapping"