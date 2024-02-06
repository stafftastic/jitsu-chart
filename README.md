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
    # or...
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

See [values.yaml](values.yaml) for more configuration options.

## Dependencies
This chart deploys the following dependencies by default in order to provide an easy out-of-the-box
experience, however for production it is recommended you deploy these separately:

* Postgres
* Redis
* Kafka
* MongoDB

In order to use your own instances of these, disable them in with their respective options:
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

Then supply the connection details in the `config` section (or specifically per service):
```yaml
config:
  databaseURL: "postgres://..."
  redisURL: "redis://..."
  kafkaBootstrapServers: "kafka:9092,..."
  mongodbURL: "mongodb://..."
```

## Configuration Options
The individual services' configuration corresponds to the environment variables they accept. For
services where every environment variable is prefixed with the service name, the prefix is stripped,
otherwise the keys are naïvely converted to camel case, with each letter that would follow an
underscore capitalized.

Many of the configuration values will be set automatically when left empty, such as connection
parameters for services deployed by the subcharts, tokens and URLs for inter-service communication
and values that can be directly derived from other values. When this is the case it is noted in the
comments above the value. Links are also provided to relevant upstream documentation.

Some configuration values contain structured data. For these you can either specify them as a string
as you would in an environment variable, or as a dict that will be converted to the appropriate
string representation by the chart.

One notable example of this, and the only exception to the 1:1 mapping of environment variables to
camel cased keys, is the `bulker.config.destination` value. The Bulker takes an arbitrary number of
destination environment variables in the form of `BULKER_DESTINATION_*`. These are represented in
`values.yaml` as a dict of either strings or dicts.

Example:

```yaml
bulker:
  config:
    destination:
      postgres:
        id: postgres
      s3: '{"id":"s3"}'
```

Becomes:

```sh
BULKER_DESTINATION_POSTGRES='{"id":"postgres"}'
BULKER_DESTINATION_S3='{"id":"s3"}'
```

## Inter-Service Authentication
The different Jitsu services communicate with each other using tokens and corresponding salted
hashes to verify. These can be managed manually, however by default they are generated by a job and
stored in a secret. Each service then gets access to the tokens they need through the environment.

In order to disable this, set `tokenGenerator.enabled` to `false` and supply the tokens manually.
