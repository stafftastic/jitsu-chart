rendered=$1
failures=0

expect() {
  local file=$1 query=$2 expected=$3 actual
  actual=$(yq ea -N "$query" "$rendered/$file")
  if [ "$actual" != "$expected" ]; then
    printf '%s: %s\n  expected: %s\n  actual:   %s\n' "$file" "$query" "$expected" "$actual"
    failures=$((failures + 1))
  fi
}

names() {
  printf '[select(.kind == "%s") | .metadata.name] | sort | join(" ")' "$1"
}

env_of() {
  printf 'select(.kind == "%s" and .metadata.name == "%s") | .spec.template.spec.containers[0].env[] | select(.name == "%s")' "$1" "$2" "$3"
}

expect defaults.yaml "$(names Deployment)" \
  "jitsu-bulker jitsu-console jitsu-ingest jitsu-mongodb jitsu-operator jitsu-rotor jitsu-syncctl"
expect defaults.yaml "$(names StatefulSet)" \
  "jitsu-clickhouse-shard0 jitsu-kafka-controller jitsu-postgresql jitsu-profiles"
expect defaults.yaml '[select(.kind == "Job") | .metadata.name | sub("-[0-9a-f]{8}$", "")] | sort | join(" ")' \
  "jitsu-clickhouse-init jitsu-event-log-init jitsu-migration jitsu-token-generator"
expect defaults.yaml '[select(.kind == "Deployment" and .metadata.labels."app.kubernetes.io/name" == "jitsu") | .spec.template.spec.containers[].image | sub(".*:", "")] | unique | join(" ")' \
  "2.14.0"
expect defaults.yaml 'select(.kind == "Ingress") | .spec.rules[0].host' "jitsu.example.com"
expect defaults.yaml 'select(.kind == "Ingress") | [.spec.rules[0].http.paths[] | .path + " " + .backend.service.name + ":" + (.backend.service.port.number | tostring)] | join(", ")' \
  "/ jitsu-console:3000, /api/s/ jitsu-ingest:3049, /v1/batch jitsu-ingest:3049, /p.js jitsu-ingest:3049"
expect defaults.yaml "$(env_of Deployment jitsu-console DATABASE_URL) | .value" \
  "postgres://jitsu:jitsu@jitsu-postgresql:5432/jitsu?schema=newjitsu"
expect defaults.yaml "$(env_of Deployment jitsu-console CLICKHOUSE_HOST) | .value" "jitsu-clickhouse:8123"

expect external-services.yaml "$(names Deployment)" \
  "jitsu-bulker jitsu-console jitsu-ingest jitsu-operator jitsu-rotor"
expect external-services.yaml "$(names StatefulSet)" "jitsu-profiles jitsu-redis-master"
expect external-services.yaml "$(names Ingress)" ""
expect external-services.yaml "$(names Secret)" ""
expect external-services.yaml "$(env_of Deployment jitsu-console DATABASE_URL) | .valueFrom.secretKeyRef | .name + \"/\" + .key" \
  "jitsu-external/database-url"
expect external-services.yaml "$(env_of Deployment jitsu-console CLICKHOUSE_PASSWORD) | .valueFrom.secretKeyRef | .name + \"/\" + .key" \
  "jitsu-external/clickhouse-password"
expect external-services.yaml "$(env_of Deployment jitsu-rotor MONGODB_URL) | .valueFrom.secretKeyRef | .name + \"/\" + .key" \
  "mongodb/url"
expect external-services.yaml "$(env_of Deployment jitsu-rotor KAFKA_BOOTSTRAP_SERVERS) | .value" \
  "kafka.example.svc.cluster.local:9092"
expect external-services.yaml "$(env_of Deployment jitsu-ingest INGEST_REDIS_URL) | .valueFrom.secretKeyRef | .name + \"/\" + .key" \
  "jitsu-external/redis-url"
expect external-services.yaml "$(env_of Deployment jitsu-ingest INGEST_CLICKHOUSE_HOST) | .value" \
  "clickhouse.example.svc.cluster.local:8123"
expect external-services.yaml '[select(.kind == "HorizontalPodAutoscaler") | .metadata.name + ":" + (.spec.minReplicas | tostring)] | sort | join(" ")' \
  "jitsu-ingest:2 jitsu-rotor:2"
expect external-services.yaml "$(names ServiceMonitor)" "jitsu-bulker jitsu-ingest"
expect external-services.yaml '[select(.kind == "ServiceMonitor") | .metadata.labels.instance] | unique | join(" ")' "default"
expect external-services.yaml "$(env_of Deployment jitsu-console GITHUB_CLIENT_SECRET) | .valueFrom.secretKeyRef | .name + \"/\" + .key" \
  "jitsu-external/github-client-secret"
expect external-services.yaml '[select(.kind == "PodDisruptionBudget" and (.metadata.name == "jitsu-bulker" or .metadata.name == "jitsu-ingest" or .metadata.name == "jitsu-rotor")) | .metadata.name + ":" + (.spec.maxUnavailable | tostring)] | sort | join(" ")' \
  "jitsu-bulker:1 jitsu-ingest:1 jitsu-rotor:1"
expect external-services.yaml '[select(.kind == "Deployment" and .spec.template.spec.topologySpreadConstraints) | .metadata.name] | sort | join(" ")' \
  "jitsu-bulker jitsu-ingest jitsu-rotor"
expect external-services.yaml 'select(.kind == "Deployment" and .metadata.name == "jitsu-rotor") | .spec.template.spec.containers[0].volumeMounts[] | select(.name == "mongodb-tls") | .mountPath' \
  "/etc/mongodb-tls"
expect external-services.yaml 'select(.kind == "Deployment" and .metadata.name == "jitsu-bulker") | .spec.template.spec.volumes[] | select(.name == "jitsu-data") | .secret.secretName' \
  "jitsu-jitsu-data"
expect external-services.yaml 'select(.kind == "StatefulSet" and .metadata.name == "jitsu-redis-master") | .spec.template.spec.containers[0].env[] | select(.name == "REDIS_PASSWORD_FILE" or .name == "REDIS_PASSWORD") | .name' \
  "REDIS_PASSWORD_FILE"
expect external-services.yaml 'select(.kind == "StatefulSet" and .metadata.name == "jitsu-redis-master") | .spec.template.spec.volumes[] | select(.name == "redis-password") | .secret.secretName' \
  "jitsu-redis"
expect external-services.yaml 'select(.kind == "StatefulSet" and .metadata.name == "jitsu-redis-master") | .spec.template.spec.containers[0].resources.requests.memory' \
  "1Gi"

if [ "$failures" -gt 0 ]; then
  echo "$failures template assertions failed"
  exit 1
fi
