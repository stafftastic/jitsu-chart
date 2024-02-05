# Jitsu Helm Chart

## TL;DR
```bash
helm install jitsu oci://registry-1.docker.io/stafftasticcharts/jitsu -f values.yaml
```

`values.yaml`:
```yaml
global:
  postgresql:
    auth:
      password: "changeMe"
console:
  config:
    jitsuPublicURL: "http://jitsu.example.com"
    jitsuIngestURL: "http://data.jitsu.example.com"
    seedUserEmail: "admin@example.com"
    seedUserPassword: "changeMe"
    # or:
    # githubClientID: "..."
    # githubClientSecret: "..."
  ingress:
    className: "nginx"
    hosts:
      - host: "jitsu.example.com"
        paths:
          - path: "/"
            pathType: "Prefix"
ingest:
  ingress:
    className: "nginx"
    hosts:
      - host: "data.jitsu.example.com"
        paths:
          - path: "/"
            pathType: "Prefix"
```

See [values.yaml](values.yaml) for more configuration options and more detailed descriptions.

## Dependencies
This chart deploys the following dependencies by default:
* Postgres
* Redis
* Kafka
* MongoDB

If you want to use your own instances of these, disable them in with their respective option:
```yaml
postgresql:
  enabled: false
redis:
  enabled: false
kafka:
  enabled: false
mongodb:
  enabled: false
```

Then supply the connection details in the `config` section:
```yaml
config:
  databaseURL: "postgres://..."
  redisURL: "redis://..."
  kafkaBootstrapServers: "kafka:9092,..."
  mongodbURL: "mongodb://..."
```
