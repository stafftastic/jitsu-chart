# Jitsu Helm Chart

## TL;DR
```bash
helm install jitsu oci://registry-1.docker.io/stafftasticcharts/jitsu -f-<<EOF
ingress:
  host: "jitsu.example.com"
console:
  config:
    seedUserEmail: "me@example.com"
    seedUserPassword: "changeMe"
EOF
```

For a production deployment it is recommended to read through `values.yaml` and make conscious
decisions in order to ensure the deployment is secure, reliable and scalable.

## Basic Configuration
`values.yaml`:
```yaml
postgresql:
  auth:
    password: "changeMe"
mongodb:
  auth:
    passwords: ["changeMe"]
redis:
  auth:
    password: "changeMe"

ingress:
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt"
  host: "jitsu.example.com"
  tls: true

console:
  config:
    # Populate with GitHub OAuth client credentials
    githubClientId: "..."
    githubClientSecret: "..."
```

Once you have logged in, set `console.config.disableSignup` to `true` to prevent anyone with a
GitHub account from using your instance.

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
  databaseUrl: "postgres://..."
  redisUrl: "redis://..."
  kafkaBootstrapServers: "kafka:9092,..."
  mongodbUrl: "mongodb://..."
```

## Configuration Options
The individual services' configuration corresponds to the environment variables they accept. For
services where every environment variable is prefixed with the service name, the prefix is stripped,
otherwise the keys are naïvely converted to camel case, with each letter that would follow an
underscore capitalized.

Some values, in particular those that contain sensitive information or connection information, also
allow you to reference a secret or configmap. In `values.yaml` these are suffixed with `From`. E.g.
to read the database URL (`config.databaseUrl`) from a secret, set it as you would an environment
variable:

```yaml
config:
  databaseUrlFrom:
    secretKeyRef:
      name: database-secret-name
      key: database-url-key
```

For the full list of variables that support this syntax, see `values.yaml`.

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

```bash
BULKER_DESTINATION_POSTGRES='{"id":"postgres"}'
BULKER_DESTINATION_S3='{"id":"s3"}'
```

## Inter-Service Authentication
The different Jitsu services communicate with each other using tokens and corresponding salted
hashes to verify. These can be managed manually, however by default they are generated by a job and
stored in a secret. Each service then gets access to the tokens they need through the environment.

In order to disable this, set `tokenGenerator.enabled` to `false` and supply the tokens manually.

## Running Connectors in a Different Namespace
By default syncctl runs connectors in the same namespace as the rest of the Jitsu services. If you
wish to run these ephemeral and to some degree user-controlled workloads in a separate namespace you
can set `syncctl.config.kubernetesNamespace` to the desired namespace, and the chart will create the
namespace, service proxies for the bulker and databse, and the necessary RBAC resources for you.
