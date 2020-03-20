#!/usr/bin/env bash

set -eu
set -o pipefail

function log {
	echo -e "\n[+] $1\n"
}

function poll_ready {
	local svc=$1
	local url=$2

	local -a args=( '-s' '-D-' '-w' '%{http_code}' "$url" )
	if [ "$#" -ge 3 ]; then
		args+=( '-u' "$3" )
	fi

	local label
	if [ "$MODE" == "swarm" ]; then
		label="com.docker.swarm.service.name=elk_${svc}"
	else
		label="com.docker.compose.service=${svc}"
	fi

	local -i result=1
	local cid
	local output

	for _ in $(seq 1 24); do
		cid="$(docker ps -q -f label="$label")"
		if [ -z "${cid:-}" ]; then
			echo "Container exited"
			return 1
		fi

		set +e
		output="$(curl "${args[@]}")"
		set -e
		if [ "${output: -3}" -eq 200 ]; then
			result=0
			break
		fi

		echo -n '.'
		sleep 5
	done

	echo -e "\n${output::-3}"

	return $result
}

declare MODE=""
if [ "$#" -ge 1 ]; then
	MODE=$1
fi

log 'En attente de Elastic'
poll_ready elasticsearch 'http://localhost:9200/' 'elastic:testpasswd'

log 'En attente de kibana'
poll_ready kibana 'http://localhost:5601/api/status' 'kibana:testpasswd'

log 'En attente de logstash'
poll_ready logstash 'http://localhost:9600/_node/pipelines/main?pretty'

log 'Création logstash pattern dans kibana'
source .env
curl -X POST -D- 'http://localhost:5601/api/saved_objects/index-pattern' \
	-s -w '\n' \
	-H 'Content-Type: application/json' \
	-H "kbn-version: ${ELK_VERSION}" \
	-u elastic:testpasswd \
	-d '{"attributes":{"title":"logstash-*","timeFieldName":"@timestamp"}}'

log 'Check de patter sur API '
response="$(curl 'http://localhost:5601/api/saved_objects/_find?type=index-pattern' -s -u elastic:testpasswd)"
echo "$response"
count="$(jq -rn --argjson data "${response}" '$data.total')"
if [[ $count -ne 1 ]]; then
	echo "Expected 1 index pattern, got ${count}"
	exit 1
fi

log 'Envoie de message sur le tcp input'
echo 'dockerelk' | nc -q0 localhost 5000

sleep 1
curl -X POST 'http://localhost:9200/_refresh' -u elastic:testpasswd \
	-s -w '\n'

log 'Recherche de message dans Elasticsearch'
response="$(curl 'http://localhost:9200/_count?q=message:dockerelk&pretty' -s -u elastic:testpasswd)"
echo "$response"
count="$(jq -rn --argjson data "${response}" '$data.count')"
if [[ $count -ne 1 ]]; then
	echo "Expected 1 document, got ${count}"
	exit 1
fi
