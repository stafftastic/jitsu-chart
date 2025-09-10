{{/*
Bulker selector labels
*/}}
{{- define "jitsu.bulker.selectorLabels" -}}
app.kubernetes.io/component: bulker
{{- end }}

{{- define "jitsu.bulker.kubectlSelectorLabels" -}}
{{- $labels := merge (dict) (include "jitsu.selectorLabels" . | fromYaml) (include "jitsu.bulker.selectorLabels" . | fromYaml) }}
{{- $args := list -}}
{{- range $k, $v := $labels -}}
{{ $args = append $args (printf "%s=%s" $k $v) -}}
{{- end -}}
{{- join "," $args -}}
{{- end }}

{{- define "jitsu.bulker.env" -}}
{{- with .Values.bulker.config }}
- name: BULKER_INSTANCE_ID
  value: {{ .instanceId | quote }}

{{- if or .redisUrlFrom $.Values.config.redisUrlFrom }}
- name: BULKER_REDIS_URL
  valueFrom:
    {{- toYaml (.redisUrlFrom | default $.Values.config.redisUrlFrom) | nindent 4 }}
{{- else }}
- name: BULKER_REDIS_URL
  value: {{ .redisUrl | default (include "jitsu.redisUrl" $) | quote }}
{{- end }}

{{- if and (not .configSource) $.Values.console.enabled $.Values.tokenGenerator.enabled }}
- name: BULKER_CONFIG_SOURCE
  value: {{ printf "http://%s-console:%d/api/admin/export/bulker-connections"
    (include "jitsu.fullname" $)
    (int $.Values.console.service.port)
  | quote }}
{{- end }}
{{- with .configSource }}
- name: BULKER_CONFIG_SOURCE
  value: {{ . | quote }}
{{- end }}

{{- if .configSourceHttpAuthTokenFrom }}
- name: BULKER_CONFIG_SOURCE_HTTP_AUTH_TOKEN
  valueFrom:
    {{- toYaml .configSourceHttpAuthTokenFrom | nindent 4 }}
{{- else }}
{{- if and (not .configSourceHttpAuthToken) $.Values.console.enabled $.Values.tokenGenerator.enabled }}
- name: BULKER_CONFIG_SOURCE_HTTP_AUTH_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: consoleAuthToken
{{- end }}
{{- with .configSourceHttpAuthToken }}
- name: BULKER_CONFIG_SOURCE_HTTP_AUTH_TOKEN
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- with .configRefreshPeriodSec }}
- name: BULKER_CONFIG_REFRESH_PERIOD_SEC
  value: {{ . | quote }}
{{- end }}

{{- range $k, $v := .destination }}
- name: {{ printf "BULKER_DESTINATION_%s" (upper $k) | quote }}
  {{- if kindIs "string" $v }}
  value: {{ $v | quote }}
  {{- else }}
  value: {{ toJson $v | quote }}
  {{- end }}
{{- end }}

{{- if .authTokensFrom }}
- name: BULKER_AUTH_TOKENS
  valueFrom:
    {{- toYaml .authTokensFrom | nindent 4 }}
{{- else }}
{{- if and (not .authTokens) $.Values.tokenGenerator.enabled }}
- name: BULKER_AUTH_TOKENS
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: bulkerAuthTokens
{{- end }}
{{- with .authTokens}}
- name: BULKER_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .tokenSecretFrom }}
- name: BULKER_TOKEN_SECRET
  valueFrom:
    {{- toYaml .tokenSecretFrom | nindent 4 }}
{{- else }}
{{- if and (not .tokenSecret) $.Values.tokenGenerator.enabled }}
- name: BULKER_TOKEN_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: globalHashSecret
{{- end }}
{{- with .tokenSecret }}
- name: BULKER_TOKEN_SECRET
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .rawAuthTokensFrom }}
- name: BULKER_RAW_AUTH_TOKENS
  valueFrom:
    {{- toYaml .rawAuthTokensFrom | nindent 4 }}
{{- else }}
{{- with .rawAuthTokens }}
- name: BULKER_RAW_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if or .globalHashSecretFrom $.Values.config.globalHashSecretFrom }}
- name: GLOBAL_HASH_SECRET
  valueFrom:
    {{- toYaml (.globalHashSecretFrom | default $.Values.config.globalHashSecretFrom) | nindent 4 }}
{{- else }}
{{- if and (not .globalHashSecret) (not $.Values.config.globalHashSecret) $.Values.tokenGenerator.enabled }}
- name: BULKER_GLOBAL_HASH_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: globalHashSecret
{{- end }}
{{- with (.globalHashSecret | default $.Values.config.globalHashSecret) }}
- name: GLOBAL_HASH_SECRET
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- with .eventsLogMaxSize }}
- name: BULKER_EVENTS_LOG_MAX_SIZE
  value: {{ . | quote }}
{{- end }}

{{- if and (not .kafkaBootstrapServers) (not $.Values.config.kafkaBootstrapServers) $.Values.kafka.enabled }}
- name: BULKER_KAFKA_BOOTSTRAP_SERVERS
  value: "{{ $.Release.Name }}-kafka:9092"
{{- end }}
{{- with (.kafkaBootstrapServers | default $.Values.config.kafkaBootstrapServers) }}
- name: BULKER_KAFKA_BOOTSTRAP_SERVERS
  value: {{ . | quote }}
{{- end }}

{{- with (.kafkaSsl | default $.Values.config.kafkaSsl) }}
- name: BULKER_KAFKA_SSL
  value: {{ . | quote }}
{{- end }}

{{- with .kafkaSslSkipVerify }}
- name: BULKER_KAFKA_SSL_SKIP_VERIFY
  value: {{ . | quote }}
{{- end }}

{{- if or .kafkaSaslFrom $.Values.config.kafkaSaslFrom }}
- name: BULKER_KAFKA_SASL
  valueFrom:
    {{- toYaml (.kafkaSaslFrom | default $.Values.config.kafkaSaslFrom) | nindent 4 }}
{{- else }}
{{- with (.kafkaSasl | default $.Values.config.kafkaSasl) }}
- name: BULKER_KAFKA_SASL
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toJson . | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{- if or .clickhouseHostFrom $.Values.config.clickhouseTcpHostFrom }}
- name: BULKER_CLICKHOUSE_HOST
  valueFrom:
    {{- toYaml (.clickhouseHostFrom | default $.Values.config.clickhouseTcpHostFrom) | nindent 4 }}
{{- else }}
- name: BULKER_CLICKHOUSE_HOST
  value: {{ .clickhouseHost | default (include "jitsu.clickhouseTcpHost" $) | quote }}
{{- end }}

{{- if or .clickhouseDatabaseFrom $.Values.config.clickhouseDatabaseFrom }}
- name: BULKER_CLICKHOUSE_DATABASE
  valueFrom:
    {{- toYaml (.clickhouseDatabaseFrom | default $.Values.config.clickhouseDatabaseFrom) | nindent 4 }}
{{- else }}
- name: BULKER_CLICKHOUSE_DATABASE
  value: {{ .clickhouseDatabase | default (include "jitsu.clickhouseDatabase" $) | quote }}
{{- end }}

{{- if or .clickhouseUsernameFrom $.Values.config.clickhouseUsernameFrom }}
- name: BULKER_CLICKHOUSE_USERNAME
  valueFrom:
    {{- toYaml (.clickhouseUsernameFrom | default $.Values.config.clickhouseUsernameFrom) | nindent 4 }}
{{- else }}
- name: BULKER_CLICKHOUSE_USERNAME
  value: {{ .clickhouseUsername | default (include "jitsu.clickhouseUsername" $) | quote }}
{{- end }}

{{- if or .clickhousePasswordFrom $.Values.config.clickhousePasswordFrom }}
- name: BULKER_CLICKHOUSE_PASSWORD
  valueFrom:
    {{- toYaml (.clickhousePasswordFrom | default $.Values.config.clickhousePasswordFrom) | nindent 4 }}
{{- else }}
- name: BULKER_CLICKHOUSE_PASSWORD
  value: {{ .clickhousePassword | default (include "jitsu.clickhousePassword" $) | quote }}
{{- end }}

{{- with (.clickhouseSsl | default $.Values.config.clickhouseSsl) }}
- name: BULKER_CLICKHOUSE_SSL
  value: {{ . | quote }}
{{- end }}

{{- with .batchRunnerDefaultPeriodSec }}
- name: BULKER_BATCH_RUNNER_DEFAULT_PERIOD_SEC
  value: {{ . | quote }}
{{- end }}

{{- with .batchRunnerDefaultBatchSize }}
- name: BULKER_BATCH_RUNNER_DEFAULT_BATCH_SIZE
  value: {{ . | quote }}
{{- end }}

{{- with .batchRunnerDefaultRetryPeriodSec }}
- name: BULKER_BATCH_RUNNER_DEFAULT_RETRY_PERIOD_SEC
  value: {{ . | quote }}
{{- end }}

{{- with .batchRunnerDefaultRetryBatchSize }}
- name: BULKER_BATCH_RUNNER_DEFAULT_RETRY_BATCH_SIZE
  value: {{ . | quote }}
{{- end }}

{{- with .messagesRetryCount }}
- name: BULKER_MESSAGES_RETRY_COUNT
  value: {{ . | quote }}
{{- end }}

{{- with .messagesRetryBackoffBase }}
- name: BULKER_MESSAGES_RETRY_BACKOFF_BASE
  value: {{ . | quote }}
{{- end }}

{{- with .messagesRetryBackoffMaxDelay }}
- name: BULKER_MESSAGES_RETRY_BACKOFF_MAX_DELAY
  value: {{ . | quote }}
{{- end }}

{{- with .kafkaTopicRetentionHours }}
- name: BULKER_KAFKA_TOPIC_RETENTION_HOURS
  value: {{ . | quote }}
{{- end }}

{{- with .kafkaRetryTopicRetentionHours }}
- name: BULKER_KAFKA_RETRY_TOPIC_RETENTION_HOURS
  value: {{ . | quote }}
{{- end }}

{{- with .kafkaDeadTopicRetentionHours }}
- name: BULKER_KAFKA_DEAD_TOPIC_RETENTION_HOURS
  value: {{ . | quote }}
{{- end }}

{{- with .kafkaTopicReplicationFactor }}
- name: BULKER_KAFKA_TOPIC_REPLICATION_FACTOR
  value: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}
